//
//  ARIB8CharDecode.swift
//  TSCaptionDecoderLib
//
//  Created by saga-dash on 2018/07/07.
//


import Foundation
import ByteArrayWrapper


var G0 = MFMode(charSet: .GSet, charTable: CharTableGset.KANJI.rawValue, byte: 2)!
var G1 = MFMode(charSet: .GSet, charTable: CharTableGset.ASCII.rawValue, byte: 1)!
var G2 = MFMode(charSet: .GSet, charTable: CharTableGset.HIRA.rawValue, byte: 1)!
var G3 = MFMode(charSet: .DRCS, charTable: CharTableDRCS.MACRO.rawValue, byte: 1)!
var GL: UnsafeMutablePointer<MFMode> = UnsafeMutablePointer(&G0)
var GR: UnsafeMutablePointer<MFMode> = UnsafeMutablePointer(&G2)

public func ARIB8charDecode(_ dataUnit: DataUnit) throws -> Unit {
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
    G0 = MFMode(charSet: .GSet, charTable: CharTableGset.KANJI.rawValue, byte: 2)!
    G1 = MFMode(charSet: .GSet, charTable: CharTableGset.ASCII.rawValue, byte: 1)!
    G2 = MFMode(charSet: .GSet, charTable: CharTableGset.HIRA.rawValue, byte: 1)!
    G3 = MFMode(charSet: .DRCS, charTable: CharTableDRCS.MACRO.rawValue, byte: 1)!
    GL = UnsafeMutablePointer(&G0)
    GR = UnsafeMutablePointer(&G2)
    return try Analyze(dataUnit.payload)
}
public func ARIB8charDecode(_ bytes: [UInt8]) throws -> Unit {
    G0 = MFMode(charSet: .GSet, charTable: CharTableGset.KANJI.rawValue, byte: 2)!
    G1 = MFMode(charSet: .GSet, charTable: CharTableGset.ASCII.rawValue, byte: 1)!
    G2 = MFMode(charSet: .GSet, charTable: CharTableGset.HIRA.rawValue, byte: 1)!
    G3 = MFMode(charSet: .GSet, charTable: CharTableGset.KANA.rawValue, byte: 1)!
    GL = UnsafeMutablePointer(&G0)
    GR = UnsafeMutablePointer(&G2)
    return try Analyze(bytes)
}
func Analyze(_ bytes: [UInt8]) throws -> Unit {
    let wrapper = ByteArray(bytes)
    var str = ""
    var controls: [Control] = []
    while 0 < wrapper.count {
        let byte = try wrapper.get(doMove: false)
        // 制御コード?
        guard let code = ControlCode(rawValue: byte) else {
            if byte <= 0x20 || (0x7F<byte && byte<=0xA0) {
                fatalError("未定義の制御コード: \(String(format: "%02x", byte))")
            }
            let control = try getChar(wrapper, GL: GL, GR: GR)
            controls.append(control)
            str += control.str ?? ""
            continue
        }
        try wrapper.skip(1) // 制御コード分
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
            controls.append(Control(code))
            GL = UnsafeMutablePointer<MFMode>(&G1)
        case .LS0:
            controls.append(Control(code))
            GL = UnsafeMutablePointer<MFMode>(&G0)
        case .PAPF:
            controls.append(Control(code, payload: try wrapper.take(1)))
        case .CAN:
            controls.append(Control(code))
        case .SS2:
            let control = try getChar(wrapper, mode: G2, code: .SS2)
            controls.append(control)
            str += control.str ?? ""
        case .ESC:
            let control = try ESC(wrapper)
            controls.append(control)
        case .APS:
            controls.append(Control(code, payload: try wrapper.take(2)))
        case .SS3:
            let control = try getChar(wrapper, mode: G3, code: .SS3)
            controls.append(control)
            str += control.str ?? ""
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
            controls.append(Control(code, payload: try wrapper.take(1)))
        case .COL:
            if try wrapper.get(doMove: false) < 0x40 {
                controls.append(Control(code, payload: try wrapper.take(2)))
            } else {
                controls.append(Control(code, payload: try wrapper.take(1)))
            }
        case .FLC:
            controls.append(Control(code, payload: try wrapper.take(1)))
        case .CDC:
            if try wrapper.get(doMove: false) < 0x40 {
                controls.append(Control(code, payload: try wrapper.take(2)))
            } else {
                controls.append(Control(code, payload: try wrapper.take(1)))
            }
        case .POL:
            controls.append(Control(code, payload: try wrapper.take(1)))
        case .WMM:
            controls.append(Control(code, payload: try wrapper.take(1)))
        case .MACRO:
            // ToDo:
            fatalError("マクロよくわからん")
            controls.append(Control(code, payload: try wrapper.take(1)))
        case .HLC:
            controls.append(Control(code, payload: try wrapper.take(1)))
        case .RPC:
            controls.append(Control(code, payload: try wrapper.take(1)))
        case .SPL:
            controls.append(Control(code))
        case .STL:
            controls.append(Control(code))
        case .CSI:
            let control = try CSI(wrapper)
            controls.append(control)
        case .TIME:
            let param1 = try wrapper.get()
            // 処理待ち: 0x20
            if param1 == 0x20 {
                controls.append(Control(code, payload: [param1, try wrapper.get()]))
                continue
            }
            // 時刻制御モード(TMD)
            assert(param1 == 0x28, "時刻制御モードのパラメータ1がおかしい: \(String(format: "0x%02x", param1))")
            controls.append(Control(code, payload: [param1, try wrapper.get()]))
        case .CHAR:
            fatalError("command: \(code), code: \(String(format: "0x%02x", byte)), 出力用なので不正")
        case .DRCS:
            fatalError("command: \(code), code: \(String(format: "0x%02x", byte)), 出力用なので不正")
        default:
            fatalError("command: \(code), code: \(String(format: "0x%02x", byte)), まだ定義してないよ!")
        }
    }
    return Unit(str: str, control: controls)
}
func setMode(src: MFMode, dist: inout MFMode) {
    dist = src
}
func getChar(_ wrapper: ByteArray, GL: UnsafeMutablePointer<MFMode>, GR: UnsafeMutablePointer<MFMode>) throws -> Control {
    let c = try wrapper.get(doMove: false)
    if c < 0x7F {
        // GL符号領域
        let control = try getChar(wrapper, mode: GL.pointee)
        return control
    } else {
        // GR符号領域
        let control = try getChar(wrapper, mode: GR.pointee)
        return control
    }
}
func getChar(_ wrapper: ByteArray, mode: MFMode, code: ControlCode = .CHAR) throws -> Control {
    //print("\(String(format: "%02x", bytes[index]))", mode)
    if numericCast(mode.byte) > wrapper.count {
        let control = Control(code, str: "$$$$", payload: try wrapper.take(1))
        return control
    }
    if mode.charSet == .GSet {
        guard let charTable = CharTableGset(rawValue: mode.charTable) else {
            fatalError("未定義のテーブル: \(String(format: "%02x", mode.charTable))")
        }
        switch charTable {
        case .ASCII, .PROP_ASCII:
            let byte = try wrapper.get()
            let str = AsciiTable[Int(byte&0x7F-0x21)]
            let control = Control(code, str: str, payload: [byte])
            return control
        case .HIRA, .PROP_HIRA:
            let byte = try wrapper.get()
            let str = HiraTable[Int(byte&0x7F-0x21)]
            let control = Control(code, str: str, payload: [byte])
            return control
        case .KANA, .JISX_KANA, .PROP_KANA:
            let byte = try wrapper.get()
            let str = KanaTable[Int(byte&0x7F-0x21)]
            let control = Control(code, str: str, payload: [byte])
            return control
        case .KANJI, .JIS_KANJI1, .JIS_KANJI2, .KIGOU:
            let byte1 = try wrapper.get()
            let byte2 = try wrapper.get()
            let str = jisToUtf16(byte1&0x7F, byte2&0x7F)
            let control = Control(code, str: str, payload: [byte1, byte2])
            return control
        case .MOSAIC_A, .MOSAIC_B, .MOSAIC_C, .MOSAIC_D:
            // ToDo
            let str = "%%%%"
            let control = Control(code, str: str, payload: try wrapper.take(Int(mode.byte)))
            return control
        default:
            fatalError("まだだよ。 \(mode)")
        }
    } else {
        guard let charTable = CharTableDRCS(rawValue: mode.charTable) else {
            fatalError("未定義のテーブル: \(String(format: "%02x", mode.charTable))")
        }
        switch charTable {
        case .DRCS_0:
            // 2byte DRCS
            // ToDo
            let str = "####"
            let control = Control(code, str: str, payload: try wrapper.take(Int(mode.byte)))
            return control
        case .DRCS_1, .DRCS_2, .DRCS_3, .DRCS_4, .DRCS_5, .DRCS_6, .DRCS_7, .DRCS_8, .DRCS_9, .DRCS_10, .DRCS_11, .DRCS_12, .DRCS_13, .DRCS_14, .DRCS_15:
            // 1byte DRCS
            // ToDo
            let str = "####"
            let control = Control(code, str: str, payload: try wrapper.take(Int(mode.byte)))
            return control
        case .MACRO:
            let byte = try wrapper.get()
            _ = try Analyze(DefaultMacro[Int(byte&0x0F)])
            let control = Control(code, str: "", payload: [byte])
            return control
        default:
            fatalError("まだだよ。 \(mode)")
        }
    }
}
func ESC(_ wrapper: ByteArray) throws -> Control {
    let bytes = try wrapper.clone().take()
    let param = bytes[0]
    if param == 0x6E {
        // G2をGLに割り当てる
        GL = UnsafeMutablePointer<MFMode>(&G2)
        try wrapper.skip(1)
        return Control(.ESC, payload: [param])
    } else if param == 0x6F {
        // G3をGLに割り当てる
        GL = UnsafeMutablePointer<MFMode>(&G3)
        try wrapper.skip(1)
        return Control(.ESC, payload: [param])
    } else if param == 0x7E {
        // G1をGRに割り当てる
        GR = UnsafeMutablePointer<MFMode>(&G1)
        try wrapper.skip(1)
        return Control(.ESC, payload: [param])
    } else if param == 0x7D {
        // G2をGRに割り当てる
        GR = UnsafeMutablePointer<MFMode>(&G2)
        try wrapper.skip(1)
        return Control(.ESC, payload: [param])
    } else if param == 0x7C {
        // G3をGRに割り当てる
        GR = UnsafeMutablePointer<MFMode>(&G3)
        try wrapper.skip(1)
        return Control(.ESC, payload: [param])
    }
    if bytes[0] == 0x24 && bytes[1] > 0x2F {
        // GセットをG0に割り当てる(2byte
        let param2 = bytes[1]
        guard let mode = MFMode(charSet: .GSet, charTable: param2, byte: 2) else {
            fatalError("未定義のテーブル1: \(String(format: "%02x", param2))")
        }
        setMode(src: mode, dist: &G0)
        try wrapper.skip(2)
        return Control(.ESC, payload: [param, param2])
    } else if bytes[0] == 0x24 && bytes[1] == 0x28 && bytes[2] == 0x20 {
        // DRCSをG0に割り当てる(2byte
        let param4 = bytes[3]
        guard let mode = MFMode(charSet: .DRCS, charTable: param4, byte: 2) else {
            fatalError("未定義のテーブル2: \(String(format: "%02x", param4))")
        }
        setMode(src: mode, dist: &G0)
        try wrapper.skip(4)
        return Control(.ESC, payload: [param, 0x28, 0x20, param4])
    } else if bytes[0] == 0x24 && bytes[1] == 0x29 && bytes[2] == 0x20 {
        // DRCSをG1に割り当てる(2byte
        let param4 = bytes[3]
        guard let mode = MFMode(charSet: .DRCS, charTable: param4, byte: 2) else {
            fatalError("未定義のテーブル3: \(String(format: "%02x", param4))")
        }
        setMode(src: mode, dist: &G1)
        try wrapper.skip(4)
        return Control(.ESC, payload: [param, 0x29, 0x20, param4])
    } else if bytes[0] == 0x24 && bytes[1] == 0x29 {
        // GセットをG1に割り当てる(2byte
        let param3 = bytes[2]
        guard let mode = MFMode(charSet: .GSet, charTable: param3, byte: 2) else {
            fatalError("未定義のテーブル4: \(String(format: "%02x", param3))")
        }
        setMode(src: mode, dist: &G1)
        try wrapper.skip(3)
        return Control(.ESC, payload: [param, 0x28, param3])
    } else if bytes[0] == 0x24 && bytes[1] == 0x2A && bytes[2] == 0x20 {
        // DRCSをG2に割り当てる(2byte
        let param4 = bytes[3]
        guard let mode = MFMode(charSet: .DRCS, charTable: param4, byte: 2) else {
            fatalError("未定義のテーブル5: \(String(format: "%02x", param4))")
        }
        setMode(src: mode, dist: &G2)
        try wrapper.skip(4)
        return Control(.ESC, payload: [param, 0x2A, 0x20, param4])
    } else if bytes[0] == 0x24 && bytes[1] == 0x2A {
        // GセットをG2に割り当てる(2byte
        let param3 = bytes[2]
        guard let mode = MFMode(charSet: .GSet, charTable: param3, byte: 2) else {
            fatalError("未定義のテーブル6: \(String(format: "%02x", param3))")
        }
        setMode(src: mode, dist: &G2)
        try wrapper.skip(3)
        return Control(.ESC, payload: [param, 0x2A, param3])
    } else if bytes[0] == 0x24 && bytes[1] == 0x2B && bytes[2] == 0x20 {
        // DRCSをG3に割り当てる(2byte
        let param4 = bytes[3]
        guard let mode = MFMode(charSet: .DRCS, charTable: param4, byte: 2) else {
            fatalError("未定義のテーブル7: \(String(format: "%02x", param4))")
        }
        setMode(src: mode, dist: &G3)
        try wrapper.skip(4)
        return Control(.ESC, payload: [param, 0x2B, 0x20, param4])
    } else if bytes[0] == 0x24 && bytes[1] == 0x2B {
        // GセットをG3に割り当てる(2byte
        let param3 = bytes[2]
        guard let mode = MFMode(charSet: .GSet, charTable: param3, byte: 2) else {
            fatalError("未定義のテーブル8: \(String(format: "%02x", param3))")
        }
        setMode(src: mode, dist: &G3)
        try wrapper.skip(3)
        return Control(.ESC, payload: [param, 0x2B, param3])
    } else if bytes[0] == 0x28 && bytes[1] == 0x20 {
        // DRCSをG0に割り当てる
        let param3 = bytes[2]
        guard let mode = MFMode(charSet: .DRCS, charTable: param3, byte: 1) else {
            fatalError("未定義のテーブル9: \(String(format: "%02x", param3))")
        }
        setMode(src: mode, dist: &G0)
        try wrapper.skip(3)
        return Control(.ESC, payload: [param, 0x20, param3])
    } else if bytes[0] == 0x28 {
        // GセットをG0に割り当てる
        let param2 = bytes[1]
        guard let mode = MFMode(charSet: .GSet, charTable: param2, byte: 1) else {
            fatalError("未定義のテーブル10: \(String(format: "%02x", param2))")
        }
        setMode(src: mode, dist: &G0)
        try wrapper.skip(2)
        return Control(.ESC, payload: [param, param2])
    } else if bytes[0] == 0x29 && bytes[1] == 0x20 {
        // DRCSをG1に割り当てる
        let param3 = bytes[2]
        guard let mode = MFMode(charSet: .DRCS, charTable: param3, byte: 1) else {
            fatalError("未定義のテーブル11: \(String(format: "%02x", param3))")
        }
        setMode(src: mode, dist: &G1)
        try wrapper.skip(3)
        return Control(.ESC, payload: [param, 0x20, param3])
    } else if bytes[0] == 0x29 {
        // GセットをG1に割り当てる
        let param2 = bytes[1]
        guard let mode = MFMode(charSet: .GSet, charTable: param2, byte: 1) else {
            fatalError("未定義のテーブル12: \(String(format: "%02x", param2))")
        }
        setMode(src: mode, dist: &G1)
        try wrapper.skip(2)
        return Control(.ESC, payload: [param, param2])
    } else if bytes[0] == 0x2A && bytes[1] == 0x20 {
        // DRCSをG2に割り当てる
        let param3 = bytes[2]
        guard let mode = MFMode(charSet: .DRCS, charTable: param3, byte: 1) else {
            fatalError("未定義のテーブル13: \(String(format: "%02x", param3))")
        }
        setMode(src: mode, dist: &G2)
        try wrapper.skip(3)
        return Control(.ESC, payload: [param, 0x20, param3])
    } else if bytes[0] == 0x2A {
        // GセットをG2に割り当てる
        let param2 = bytes[1]
        guard let mode = MFMode(charSet: .GSet, charTable: param2, byte: 1) else {
            fatalError("未定義のテーブル14: \(String(format: "%02x", param2))")
        }
        setMode(src: mode, dist: &G2)
        try wrapper.skip(2)
        return Control(.ESC, payload: [param, param2])
    } else if bytes[0] == 0x2B && bytes[1] == 0x20 {
        // DRCSをG3に割り当てる
        let param3 = bytes[2]
        guard let mode = MFMode(charSet: .DRCS, charTable: param3, byte: 1) else {
            fatalError("未定義のテーブル15: \(String(format: "%02x", param3))")
        }
        setMode(src: mode, dist: &G3)
        try wrapper.skip(3)
        return Control(.ESC, payload: [param, 0x20, param3])
    } else if bytes[0] == 0x2B {
        // GセットをG3に割り当てる
        let param2 = bytes[1]
        guard let mode = MFMode(charSet: .GSet, charTable: param2, byte: 1) else {
            fatalError("未定義のテーブル16: \(String(format: "%02x", param2))")
        }
        setMode(src: mode, dist: &G3)
        try wrapper.skip(2)
        return Control(.ESC, payload: [param, param2])
    }
    fatalError("未定義のパラメータ: \(String(format: "%02x", param))")
}
func CSI(_ wrapper: ByteArray) throws -> Control {
    var param = 0
    var command = ""
    var bytes = try wrapper.clone().take()
    // CSIの最長10byte？
    for i in 0..<10 {
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
    let control = Control(.CSI, command: command, payload: try wrapper.take(param + 2)) // param + 中間文字 + 終端文字
    return control
}

struct MFMode {
    let charSet: CharSet
    let charTable: UInt8 // CharTableGset or CharTableDRCS
    let byte: UInt8
    init?(charSet: CharSet, charTable: UInt8, byte: UInt8) {
        self.charSet = charSet
        self.byte = byte
        if charSet == .GSet {
            guard let table = CharTableGset(rawValue: charTable) else {
                return nil
            }
            self.charTable = table.rawValue
        } else {
            guard let table = CharTableDRCS(rawValue: charTable) else {
                return nil
            }
            self.charTable = table.rawValue
        }
    }
}
extension MFMode : CustomStringConvertible {
    var description: String {
        return "MFMode(charSet: \(charSet)"
            + ", charTable: \(charTable)"
            + ", byte: \(byte)"
            + ")"
    }
}
