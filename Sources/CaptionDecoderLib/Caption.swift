// 
//  Caption.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/06.
//


import Foundation

let SYNCHRONIZED_PES = 0x80
let ASYNCHRONOUS_PES = 0x81
let UNUSED = 0xFF

// ARIB STD-B24 第三編 第5章 独立 PES 伝送方式
// ARIB STD-B24 第一編 第 3 部 第9章 字幕・文字スーパーの伝送 表 9-1 データグループ
public struct Caption {
    public let header: TransportPacket
    public let pesHeader: PacketizedElementaryStream
    // --- Synchronized_PES_data ---
    public let dataIdentifier: UInt8               //  8 uimsbf
    public let privateStreamId: UInt8              //  8 uimsbf
    //public let reservedFutureUse: UInt8          //  4 uimsbf
    public let pesDataPacketHeaderLength: UInt8    //  4 uimsbf
    // --- caption_data ---
    public let dataGroupId: UInt8                  //  6 uimsbf DGI
    public let dataGroupVersion: UInt8             //  2 bslbf
    public let dataGroupLinkNumber: UInt8          //  8 uimsbf
    public let lastDataGroupLinkNumber: UInt8      //  8 uimsbf
    public let dataGroupSize: UInt16               // 16 uimsbf
    public let TMD: UInt8                          //  2 uimsbf
    //public let _reserved1: UInt8                 //  6 bslbf
    public let STM: UInt64?                        // 36 uimsbf TMDによる
    //public let _reserved1: UInt8?                //  4 bslbf  TMDによる
    public let dataUnitLoopLength: UInt32          // 24 uimsbf
    public let dataUnit: [DataUnit]                //  5 byte + 1*n byte
    // --- Synchronized_PES_data ---
    public let CRC_16: UInt16                    // 16 rpchof
    public let payload: [UInt8]                    //  n byte
    public init?(_ data: Data, _ _header: TransportPacket? = nil) {
        self.header = _header ?? TransportPacket(data)
        var bytes = header.payload
        if !(bytes[0] == 0x00 && bytes[1] == 0x0 && bytes[2] == 0x01) {
            return nil
        }
        self.pesHeader = PacketizedElementaryStream(data, header)
        bytes = pesHeader.payload
        self.dataIdentifier = bytes[0]
        self.privateStreamId = bytes[1]
        self.pesDataPacketHeaderLength = bytes[2]&0x0F
        // 同期型 PES: 0x80, 非同期型 PES パケット: 0x81
        if bytes[0] != SYNCHRONIZED_PES && bytes[0] != ASYNCHRONOUS_PES {
            print("字幕か文字スーパーである")
            return nil
        }
        if bytes[1] != UNUSED {
            return nil
        }
        // 3 byte(headerSizeまで), 5 byte(文字の最小サイズ)
        if bytes.count < pesDataPacketHeaderLength+3+5 {
            //print("header分のpayloadが足りない")
            return nil
        }
        bytes = Array(bytes.suffix(bytes.count - numericCast(3+pesDataPacketHeaderLength))) // 3 byte(headerSizeまで) + 可変長分
        self.dataGroupId = bytes[0]>>2
        self.dataGroupVersion = bytes[0]&0x03
        self.dataGroupLinkNumber = bytes[1]
        self.lastDataGroupLinkNumber = bytes[2]
        self.dataGroupSize = UInt16(bytes[3])<<8 | UInt16(bytes[4])
        self.TMD = bytes[5]>>6
        // 時刻制御モード: フリー: 0x00, リアルタイム: 0x01, オフセットタイム: 0x10
        let isManagedTime = bytes[5]>>6 == 0x01 || bytes[5]>>6 == 0x10
        let offset = isManagedTime ? 5 : 0
        if isManagedTime {
            self.STM = UInt64(bytes[5]&0x0F)<<32 | UInt64(bytes[6])<<24 | UInt64(bytes[7])<<16 | UInt64(bytes[8])<<8 | UInt64(bytes[9])
        } else {
            self.STM = nil
        }
        self.dataUnitLoopLength = UInt32(bytes[offset+5])<<16 | UInt32(bytes[offset+6])<<8 | UInt32(bytes[offset+7])
        if bytes.count < dataGroupSize + 5 + 2 { // 5 byte(DataUnit?) + 2 byte(CRC)
            //print("payloadが足りない")
            //print(bytes.count, dataGroupSize, pesHeader.packetLength)
            return nil
        }
        bytes = Array(bytes.suffix(bytes.count - numericCast(offset+9))) // 9 byte(Captionサイズ?)
        bytes = Array(bytes.prefix(numericCast(dataGroupSize) - 4 + 2)) // 4 byte(dataGroupSizeからCaptionの終わりまで), 2 byte(CRC)
        self.payload = bytes
        var payloadLength = bytes.count
        var array: [DataUnit] = []
        repeat {
            guard let dataUnit = DataUnit(bytes) else {
                //ToDo:
                if array.count != 0 {
                    //print("データユニット分離符号がない")
                    //printHexDumpForBytes(bytes: bytes)
                }
                break
            }
            array.append(dataUnit)
            let sub = 5+Int(dataUnit.dataUnitSize) // 5byte+可変長(DataUnit)
            bytes = Array(bytes.suffix(bytes.count - sub))
            payloadLength -= numericCast(sub)
        } while payloadLength > 2 // 2 byte(CRC)
        self.dataUnit = array
        self.CRC_16 = UInt16(bytes[bytes.count-2])<<8 | UInt16(bytes[bytes.count-1])
        let headerLength = 3 + pesDataPacketHeaderLength // 3 byte(headerSizeまで) + 可変長分
        let crcBytes = Array(pesHeader.payload[numericCast(headerLength)..<pesHeader.payload.count-2]) // 2 byte(CRC)
        let calcCRC16 = crc16(crcBytes)!
        if CRC_16 != calcCRC16 {
            //print("\(String(format: "0x%04x", CRC_16))", "\(String(format: "0x%04x", calcCRC16))")
            return nil
        }
    }
}
extension Caption : CustomStringConvertible {
    public var description: String {
        return "Caption(PID: \(String(format: "0x%04x", header.PID))"
            + ", dataGroupId: \(String(format: "0x%02x", dataGroupId))"
            + ", dataGroupSize: \(String(format: "0x%04x", dataGroupSize))"
            + ", dataUnitLoopLength: \(String(format: "0x%08x", dataUnitLoopLength))"
            + ", dataUnit: \(dataUnit)"
            + ", CRC_16: \(String(format: "0x%04x", CRC_16))"
            + ")"
    }
}
extension Caption {
    var hexDump: [UInt8] {
        return pesHeader.payload
    }
}
// ARIB STD-B24 第一編 第 3 部 第9章 字幕・文字スーパーの伝送 表 9-11 データユニット
public struct DataUnit {
    public let unitSeparator: UInt8          //  8 uimsbf
    public let dataUnitParameter: UInt8      //  8 uimsbf
    public let dataUnitSize: UInt32          // 24 uimsbf
    public let payload: [UInt8]
    public init?(_ bytes: [UInt8]) {
        // データユニット分離符号: 0x1F
        if bytes[0] != 0x1F {
            return nil
        }
        self.unitSeparator = bytes[0]
        self.dataUnitParameter = bytes[1]
        self.dataUnitSize = UInt32(bytes[2])<<16 | UInt32(bytes[3])<<8 | UInt32(bytes[4])
        self.payload = Array(bytes[5..<5+numericCast(dataUnitSize)])
    }
}
extension DataUnit : CustomStringConvertible {
    public var description: String {
        return "DataUnit(unitSeparator: \(String(format: "0x%02x", unitSeparator))"
            + ", dataUnitParameter: \(String(format: "0x%02x", dataUnitParameter))"
            + ", dataUnitSize: \(String(format: "0x%04x", dataUnitSize))"
            //+ ", dataUnitLoopLength: \(String(format: "0x%08x", dataUnitLoopLength))"
            + ")"
    }
}
