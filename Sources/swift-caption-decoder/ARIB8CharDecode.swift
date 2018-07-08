//
//  ARIB8CharDecode.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/07.
//


import Foundation


var G0 = MFMode(charSet: .GSet, charTable: .KANJI, byte: 2)
var G1 = MFMode(charSet: .GSet, charTable: .ASCII, byte: 1)
var G2 = MFMode(charSet: .GSet, charTable: .HIRA, byte: 1)
var G3 = MFMode(charSet: .GSet, charTable: .MACRO, byte: 1)
var GL: UnsafeMutablePointer<MFMode> = UnsafeMutablePointer(&G0)
var GR: UnsafeMutablePointer<MFMode> = UnsafeMutablePointer(&G2)

func ARIB8charDecode(_ dataUnit: DataUnit) -> Unit {
    // ARIB STD-B24 第一編 第 3 部 第9章 字幕・文字スーパーの伝送 表 9-11 データユニット
    // データユニット分離符号: 0x1F
    if dataUnit.unitSeparator != 0x1F {
        fatalError("データユニット分離符号がないやん！")
    }
    // ARIB STD-B24 第一編 第 3 部 表 9-12 データユニットの種類
    // 本文: 0x20
    if dataUnit.dataUnitParameter != 0x20 {
        fatalError("本文じゃないやん！")
    }
    G0 = MFMode(charSet: .GSet, charTable: .KANJI, byte: 2)
    G1 = MFMode(charSet: .GSet, charTable: .ASCII, byte: 1)
    G2 = MFMode(charSet: .GSet, charTable: .HIRA, byte: 1)
    G3 = MFMode(charSet: .GSet, charTable: .MACRO, byte: 1)
    GL = UnsafeMutablePointer(&G0)
    GR = UnsafeMutablePointer(&G2)
    return Analyze(dataUnit.payload)
}
func Analyze(_ bytes: [UInt8]) -> Unit {
    var index = 0
    var str = ""
    var controls: [Control] = []
    while index < bytes.count {
        let byte = bytes[index]
        guard let code = ControlCode(rawValue: byte) else {
            if byte <= 0x20 || (0x7F<byte && byte<=0xA0) {
                fatalError("未定義の制御コード: \(String(format: "%02x", byte))")
            }
            str += getChar(bytes, index: &index, GL: GL, GR: GR)
            continue
        }
        index += 1
        switch code {
        case .NULL:
            controls.append(Control(code))
        case .BEL:
            controls.append(Control(code))
        case .APB:
            controls.append(Control(code))
        case .APF:
            controls.append(Control(code))
        case .APD:
            controls.append(Control(code))
        case .APU:
            controls.append(Control(code))
        case .CS:
            controls.append(Control(code))
        case .APR:
            controls.append(Control(code))
        case .LS1:
            GL = UnsafeMutablePointer<MFMode>(&G1)
        case .LS0:
            GL = UnsafeMutablePointer<MFMode>(&G0)
        case .PAPF:
            controls.append(Control(code, payload: [bytes[index]]))
            index += 1
        case .CAN:
            controls.append(Control(code))
        case .SS2:
            str += getChar(bytes, index: &index, mode: G2)
        case .ESC:
            let param = bytes[index]
            if param == 0x6E {
                // G2をGLに割り当てる
                GL = UnsafeMutablePointer<MFMode>(&G2)
                index += 1
                continue
            } else if param == 0x6F {
                // G3をGLに割り当てる
                GL = UnsafeMutablePointer<MFMode>(&G3)
                index += 1
                continue
            } else if param == 0x7E {
                // G1をGRに割り当てる
                GR = UnsafeMutablePointer<MFMode>(&G1)
                index += 1
                continue
            } else if param == 0x7D {
                // G2をGRに割り当てる
                GR = UnsafeMutablePointer<MFMode>(&G2)
                index += 1
                continue
            } else if param == 0x7C {
                // G3をGRに割り当てる
                GR = UnsafeMutablePointer<MFMode>(&G3)
                index += 1
                continue
            }
            if param == 0x24 {
                // 2 byte テーブルを参照
                let param2 = bytes[index+1]
                if param2 > 0x2F {
                    // param2はテーブル(Gセット)
                    // GセットをG0に割り当てる
                    guard let table = CharTable(rawValue: param2) else {
                        fatalError("未定義のテーブル1: \(String(format: "%02x", param2))")
                    }
                    let mode = MFMode(charSet: .GSet, charTable: table, byte: 2)
                    setMode(src: mode, dist: &G0)
                    index += 2
                    continue
                }  else if param2 == 0x29 {
                    // GセットをG1に割り当てる
                    let param3 = bytes[index+2]
                    guard let table = CharTable(rawValue: param3) else {
                        fatalError("未定義のテーブル2: \(String(format: "%02x", param3))")
                    }
                    let mode = MFMode(charSet: .GSet, charTable: table, byte: 2)
                    setMode(src: mode, dist: &G1)
                    index += 3
                    continue
                } else if param2 == 0x2A {
                    // GセットをG2に割り当てる
                    let param3 = bytes[index+2]
                    guard let table = CharTable(rawValue: param3) else {
                        fatalError("未定義のテーブル3: \(String(format: "%02x", param3))")
                    }
                    let mode = MFMode(charSet: .GSet, charTable: table, byte: 2)
                    setMode(src: mode, dist: &G2)
                    index += 3
                    continue
                } else if param2 == 0x2B {
                    // GセットをG3に割り当てる
                    let param3 = bytes[index+2]
                    guard let table = CharTable(rawValue: param3) else {
                        fatalError("未定義のテーブル4: \(String(format: "%02x", param3))")
                    }
                    let mode = MFMode(charSet: .GSet, charTable: table, byte: 2)
                    setMode(src: mode, dist: &G3)
                    index += 3
                    continue
                }
            } else if param == 0x28 {
                // GセットをG0に割り当てる
                let param2 = bytes[index+1]
                guard let table = CharTable(rawValue: param2) else {
                    if param2 == 0x20 {
                        // ToDo: マクロのみ定義
                        let param3 = bytes[index+2]
                        guard let table = CharTable(rawValue: param3) else {
                            fatalError("未定義のテーブル5: \(String(format: "%02x", param2))")
                        }
                        // ToDo: byte==1 マクロ
                        let mode = MFMode(charSet: .GSet, charTable: table, byte: 1)
                        setMode(src: mode, dist: &G3)
                        index += 3
                        continue
                    }
                    fatalError("未定義のテーブル5: \(String(format: "%02x", param2))")
                }
                let mode = MFMode(charSet: .GSet, charTable: table, byte: 1)
                setMode(src: mode, dist: &G0)
                index += 2
                continue
            } else if param == 0x29 {
                // GセットをG1に割り当てる
                let param2 = bytes[index+1]
                guard let table = CharTable(rawValue: param2) else {
                    if param2 == 0x20 {
                        // ToDo: マクロのみ定義
                        let param3 = bytes[index+2]
                        guard let table = CharTable(rawValue: param3) else {
                            fatalError("未定義のテーブル6: \(String(format: "%02x", param2))")
                        }
                        // ToDo: byte==1 マクロ
                        let mode = MFMode(charSet: .GSet, charTable: table, byte: 1)
                        setMode(src: mode, dist: &G3)
                        index += 3
                        continue
                    }
                    fatalError("未定義のテーブル6: \(String(format: "%02x", param2))")
                }
                let mode = MFMode(charSet: .GSet, charTable: table, byte: 1)
                setMode(src: mode, dist: &G1)
                index += 2
                continue
            } else if param == 0x2A {
                // GセットをG2に割り当てる
                let param2 = bytes[index+1]
                guard let table = CharTable(rawValue: param2) else {
                    if param2 == 0x20 {
                        // ToDo: マクロのみ定義
                        let param3 = bytes[index+2]
                        guard let table = CharTable(rawValue: param3) else {
                            fatalError("未定義のテーブル7: \(String(format: "%02x", param2))")
                        }
                        // ToDo: byte==1 マクロ
                        let mode = MFMode(charSet: .GSet, charTable: table, byte: 1)
                        setMode(src: mode, dist: &G3)
                        index += 3
                        continue
                    }
                    fatalError("未定義のテーブル7: \(String(format: "%02x", param2))")
                }
                let mode = MFMode(charSet: .GSet, charTable: table, byte: 1)
                setMode(src: mode, dist: &G2)
                index += 2
                continue
            } else if param == 0x2B {
                // GセットをG3に割り当てる
                let param2 = bytes[index+1]
                guard let table = CharTable(rawValue: param2) else {
                    if param2 == 0x20 {
                        // ToDo: マクロのみ定義
                        let param3 = bytes[index+2]
                        guard let table = CharTable(rawValue: param3) else {
                            fatalError("未定義のテーブル8: \(String(format: "%02x", param2))")
                        }
                        // ToDo: byte==1 マクロ
                        let mode = MFMode(charSet: .GSet, charTable: table, byte: 1)
                        setMode(src: mode, dist: &G3)
                        index += 3
                        continue
                    }
                    fatalError("未定義のテーブル8: \(String(format: "%02x", param2))")
                }
                let mode = MFMode(charSet: .GSet, charTable: table, byte: 1)
                setMode(src: mode, dist: &G3)
                index += 2
                continue
            }
            fatalError("未定義のパラメータ: \(String(format: "%02x", param))")
        case .APS:
            controls.append(Control(code, payload: [bytes[index], bytes[index+1]]))
            index += 2
        case .SS3:
            str += getChar(bytes, index: &index, mode: G3)
        case .RS:
            controls.append(Control(code))
        case .US:
            controls.append(Control(code))
        case .SP:
            controls.append(Control(code))
        case .DEL:
            controls.append(Control(code))
        case .BKF:
            controls.append(Control(code))
        case .RDF:
            controls.append(Control(code))
        case .GRF:
            controls.append(Control(code))
        case .YLF:
            controls.append(Control(code))
        case .BLF:
            controls.append(Control(code))
        case .MGF:
            controls.append(Control(code))
        case .CNF:
            controls.append(Control(code))
        case .WHF:
            controls.append(Control(code))
        case .SSZ:
            controls.append(Control(code))
        case .MSZ:
            controls.append(Control(code))
        case .NSZ:
            controls.append(Control(code))
        case .SZX:
            controls.append(Control(code, payload: [bytes[index]]))
            index += 1
        case .COL:
            if bytes[index] < 0x40 {
                controls.append(Control(code, payload: [bytes[index], bytes[index+1]]))
                index += 2
            } else {
                controls.append(Control(code, payload: [bytes[index]]))
                index += 1
            }
        case .FLC:
            controls.append(Control(code, payload: [bytes[index]]))
            index += 1
        case .CDC:
            if bytes[index] < 0x40 {
                controls.append(Control(code, payload: [bytes[index], bytes[index+1]]))
                index += 2
            } else {
                controls.append(Control(code, payload: [bytes[index]]))
                index += 1
            }
        case .POL:
            controls.append(Control(code, payload: [bytes[index]]))
            index += 1
        case .WMM:
            controls.append(Control(code, payload: [bytes[index]]))
            index += 1
        case .MACRO:
            // ToDo:
            fatalError("マクロよくわからん")
            controls.append(Control(code, payload: [bytes[index]]))
            index += 1
        case .HLC:
            controls.append(Control(code, payload: [bytes[index]]))
            index += 1
        case .RPC:
            controls.append(Control(code, payload: [bytes[index]]))
            index += 1
        case .SPL:
            controls.append(Control(code))
        case .STL:
            controls.append(Control(code))
        case .CSI:
            let control = CSI(bytes, index: &index)
            controls.append(control)
        case .TIME:
            let param1 = bytes[index]
            // 処理待ち: 0x20
            if param1 == 0x20 {
                controls.append(Control(code, payload: [bytes[index+1]]))
                index += 2
                continue
            }
            // 時刻制御モード(TMD)
            assert(param1 == 0x28, "時刻制御モードのパラメータ1がおかしい: \(String(format: "0x%02x", param1))")
            controls.append(Control(code, payload: [param1, bytes[index+1]]))
            index += 2
        default:
            fatalError("command: \(code), code: \(String(format: "0x%02x", byte)), まだ定義してないよ!")
        }
    }
    return Unit(str: str, control: controls)
}
func setMode(src: MFMode, dist: inout MFMode) {
    dist = src
}
func getChar(_ bytes: [UInt8], index: inout Int, GL: UnsafeMutablePointer<MFMode>, GR: UnsafeMutablePointer<MFMode>) -> String {
    let c = bytes[index]
    if c < 0x7F {
        // GL符号領域
        let str = getChar(bytes, index: &index, mode: GL.pointee)
        return str
    } else {
        // GR符号領域
        let str = getChar(bytes, index: &index, mode: GR.pointee)
        return str
    }
}
func getChar(_ bytes: [UInt8], index: inout Int, mode: MFMode) -> String {
    //print("\(String(format: "%02x", bytes[index]))", mode)
    switch mode.charTable {
    case .ASCII, .PROP_ASCII:
        let str = AsciiTable[Int(bytes[index]&0x7F-0x21)]
        index += Int(mode.byte)
        return str
    case .HIRA, .PROP_HIRA:
        let str = HiraTable[Int(bytes[index]&0x7F-0x21)]
        index += Int(mode.byte)
        return str
    case .KANA, .JISX_KANA, .PROP_KANA:
        let str = KanaTable[Int(bytes[index]&0x7F-0x21)]
        index += Int(mode.byte)
        return str
    case .KANJI, .JIS_KANJI1, .JIS_KANJI2, .KIGOU:
        let str = jis_to_utf16(bytes[index]&0x7F, bytes[index+1]&0x7F)
        index += Int(mode.byte)
        return str
    case .MOSAIC_A, .MOSAIC_B, .MOSAIC_C, .MOSAIC_D:
        let str = "%%%%"
        index += Int(mode.byte)
        return str
    case .MACRO:
        _ = Analyze(DefaultMacro[Int(bytes[index]&0x0F)])
        index += Int(mode.byte)
        return ""
    default:
        fatalError("まだだよ。 \(mode)")
    }
}
func CSI(_ bytes: [UInt8], index: inout Int) -> Control {
    var param = 0
    var command = ""
    // CSIの最長10byte？
    for i in index..<index+10 {
        let c = bytes[i]
        // 中間文字: 0x20
        if c != 0x20 {
            param += 1
            continue
        }
        let next = bytes[i+1]
        // 終端文字: 0x50~
        assert(next > 0x50, "終端文字がおかしい1: \(String(format: "0x%02x", next))")
        guard let csiChar = CSIChar(rawValue: next) else {
            fatalError("終端文字がおかしい2: \(String(format: "0x%02x", next))")
        }
        command = "\(csiChar)"
        break
    }
    index += param + 2 // param + 中間文字 + 終端文字
    let control = Control(.CSI, command: command, payload: Array(bytes[0..<param]))
    return control
}
struct Unit {
    let str: String
    let control: [Control]
}
struct Control {
    let command: String
    let code: ControlCode
    let payload: [UInt8]
    init(_ code: ControlCode, command: String? = nil, payload: [UInt8] = []) {
        self.command = command ?? "\(code)"
        self.code = code
        self.payload = payload
    }
}
extension Control : CustomStringConvertible {
    var description: String {
        return "Control(command: \(command)"
            + ", code: \(code)"
            + ", payload: \(payload)"
            + ")"
    }
}

enum ControlCode: UInt8 {
    case NULL   = 0x00
    case BEL    = 0x07
    case APB    = 0x08
    case APF    = 0x09
    case APD    = 0x0A
    case APU    = 0x0B
    case CS     = 0x0C
    case APR    = 0x0D
    case LS1    = 0x0E
    case LS0    = 0x0F
    case PAPF   = 0x16
    case CAN    = 0x18
    case SS2    = 0x19
    case ESC    = 0x1B
    case APS    = 0x1C
    case SS3    = 0x1D
    case RS     = 0x1E
    case US     = 0x1F
    case SP     = 0x20
    case DEL    = 0x7F
    case BKF    = 0x80
    case RDF    = 0x81
    case GRF    = 0x82
    case YLF    = 0x83
    case BLF    = 0x84
    case MGF    = 0x85
    case CNF    = 0x86
    case WHF    = 0x87
    case SSZ    = 0x88
    case MSZ    = 0x89
    case NSZ    = 0x8A
    case SZX    = 0x8B
    case COL    = 0x90
    case FLC    = 0x91
    case CDC    = 0x92
    case POL    = 0x93
    case WMM    = 0x94
    case MACRO  = 0x95
    case HLC    = 0x97
    case RPC    = 0x98
    case SPL    = 0x99
    case STL    = 0x9A
    case CSI    = 0x9B
    case TIME   = 0x9D
    //    case 10/0   = 0xA0
    //    case 15/15  = 0xFF
}
enum CSIChar: UInt8 {
    case SWF    = 0x53
    case CCC    = 0x54
    case RCS    = 0x6E
    case ACPS   = 0x61
    case SDF    = 0x56
    case SDP    = 0x5F
    case SSM    = 0x57
    case PLD    = 0x5B
    case PLU    = 0x5C
    case SHS    = 0x58
    case SVS    = 0x59
    case GSM    = 0x42
    case GAA    = 0x5D
    case SRC    = 0x5E
    case TCC    = 0x62
    case CFS    = 0x65
    case ORN    = 0x63
    case MDF    = 0x64
    case XCS    = 0x66
    case PRA    = 0x68
    case ACS    = 0x69
    case UED    = 0x6A
    case SCS    = 0x6F
}
struct MFMode {
    let charSet: CharSet
    let charTable: CharTable
    let byte: UInt8
}
extension MFMode : CustomStringConvertible {
    var description: String {
        return "MFMode(charSet: \(charSet)"
            + ", charTable: \(charTable)"
            + ", byte: \(byte)"
            + ")"
    }
}
enum CharSet {
    case GSet
    case DRCS
}
enum CharTable: UInt8 {
    case JIS_KANJI1     = 0x39 //JIS互換漢字1面
    case JIS_KANJI2     = 0x3A //JIS互換漢字2面
    case KIGOU          = 0x3B //追加記号
    case ASCII          = 0x4A //英数
    case HIRA           = 0x30 //平仮名
    case KANA           = 0x31 //片仮名
    case KANJI          = 0x42 //漢字
    case MOSAIC_A       = 0x32 //モザイクA
    case MOSAIC_B       = 0x33 //モザイクB
    case MOSAIC_C       = 0x34 //モザイクC
    case MOSAIC_D       = 0x35 //モザイクD
    case PROP_ASCII     = 0x36 //プロポーショナル英数
    case PROP_HIRA      = 0x37 //プロポーショナル平仮名
    case PROP_KANA      = 0x38 //プロポーショナル片仮名
    case JISX_KANA      = 0x49 //JIX X0201片仮名}
    case MACRO          = 0x70 //マクロ
}
