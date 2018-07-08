// 
//  ARIB8CharDecode.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/07.
//


import Foundation


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
    var index = 0
    var str = ""
    var controls: [Control] = []
    while index < dataUnit.payload.count {
        let byte = dataUnit.payload[index]
        index += 1
        guard let code = ControlCode(rawValue: byte) else {
            if byte <= 0x20 || (0x7F<byte && byte<=0xA0) {
                fatalError("未定義の制御コード: \(String(format: "%02x", byte))")
            }
            // ToDo: 変換するやーつ
            str += "\(String(format: "%02x", byte))"
            continue
        }
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
            print("LS1ないで")
            // *****
        case .LS0:
            print("LS0ないで")
            // *****
        case .PAPF:
            controls.append(Control(code, payload: [dataUnit.payload[index]]))
            index += 1
        case .CAN:
            controls.append(Control(code))
        case .SS2:
            print("SS2ないで")
        // *****
        case .ESC:
            print("ESCないで")
        // *****
        case .APS:
            controls.append(Control(code, payload: [dataUnit.payload[index], dataUnit.payload[index+1]]))
            index += 2
        case .SS3:
            print("SS3ないで")
        // *****
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
            controls.append(Control(code, payload: [dataUnit.payload[index]]))
            index += 1
        case .COL:
            if dataUnit.payload[index] < 0x40 {
                controls.append(Control(code, payload: [dataUnit.payload[index], dataUnit.payload[index+1]]))
                index += 2
            } else {
                controls.append(Control(code, payload: [dataUnit.payload[index]]))
                index += 1
            }
        case .FLC:
            controls.append(Control(code, payload: [dataUnit.payload[index]]))
            index += 1
        case .CDC:
            if dataUnit.payload[index] < 0x40 {
                controls.append(Control(code, payload: [dataUnit.payload[index], dataUnit.payload[index+1]]))
                index += 2
            } else {
                controls.append(Control(code, payload: [dataUnit.payload[index]]))
                index += 1
            }
        case .POL:
            controls.append(Control(code, payload: [dataUnit.payload[index]]))
            index += 1
        case .WMM:
            controls.append(Control(code, payload: [dataUnit.payload[index]]))
            index += 1
        case .MACRO:
            controls.append(Control(code, payload: [dataUnit.payload[index]]))
            index += 1
        case .HLC:
            controls.append(Control(code, payload: [dataUnit.payload[index]]))
            index += 1
        case .RPC:
            controls.append(Control(code, payload: [dataUnit.payload[index]]))
            index += 1
        case .SPL:
            controls.append(Control(code))
        case .STL:
            controls.append(Control(code))
        case .CSI:
            let control = CSI(dataUnit.payload, index: &index)
            controls.append(control)
        case .TIME:
            let param1 = dataUnit.payload[index]
            // 処理待ち: 0x20
            if param1 == 0x20 {
                controls.append(Control(code, payload: [dataUnit.payload[index+1]]))
                index += 2
                continue
            }
            // 時刻制御モード(TMD)
            assert(param1 == 0x28, "時刻制御モードのパラメータ1がおかしい: \(String(format: "0x%02x", param1))")
            controls.append(Control(code, payload: [param1, dataUnit.payload[index+1]]))
            index += 2
        default:
            fatalError("command: \(code), code: \(String(format: "0x%02x", byte)), まだ定義してないよ!")
        }
    }
    return Unit(str: str, control: controls)
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
