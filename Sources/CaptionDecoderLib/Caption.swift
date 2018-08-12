// 
//  Caption.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/06.
//


import Foundation
import ByteArrayWrapper

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
    public init?(_ data: Data) throws {
        self.header = try getHeader(data, isPes: true)
        let bytes = header.payload
        if !(bytes[0] == 0x00 && bytes[1] == 0x0 && bytes[2] == 0x01) {
            return nil
        }
        guard let pesHeader = try PacketizedElementaryStream(data, header) else {
            return nil
        }
        self.pesHeader = pesHeader
        let wrapper = ByteArray(pesHeader.payload)
        let dataIdentifier = try wrapper.get()
        self.dataIdentifier = dataIdentifier
        self.privateStreamId = try wrapper.get()
        self.pesDataPacketHeaderLength = try wrapper.get()&0x0F
        // 同期型 PES: 0x80, 非同期型 PES パケット: 0x81
        if dataIdentifier != SYNCHRONIZED_PES && dataIdentifier != ASYNCHRONOUS_PES {
            print("字幕か文字スーパーである")
            return nil
        }
        if privateStreamId != UNUSED {
            return nil
        }
        // 3 byte(headerSizeまで), 5 byte(文字の最小サイズ)
        if bytes.count < pesDataPacketHeaderLength+3+5 {
            //print("header分のpayloadが足りない")
            return nil
        }
        try wrapper.skip(Int(pesDataPacketHeaderLength)) // 可変長分
        self.dataGroupId = try wrapper.get(doMove: false)>>2
        self.dataGroupVersion = try wrapper.get()&0x03
        self.dataGroupLinkNumber = try wrapper.get()
        self.lastDataGroupLinkNumber = try wrapper.get()
        self.dataGroupSize = UInt16(try wrapper.get(num: 2))
        let TMD = try wrapper.get(doMove: false)>>6
        self.TMD = TMD
        _ = try wrapper.get()
        // 時刻制御モード: フリー: 0x00, リアルタイム: 0x01, オフセットタイム: 0x10
        let isManagedTime = TMD == 0x01 || TMD == 0x10
        if isManagedTime {
            self.STM = UInt64(try wrapper.get(num: 5)&0xFFFFFFFFF0)
        } else {
            self.STM = nil
        }
        self.dataUnitLoopLength = UInt32(try wrapper.get(num: 3))
        if bytes.count < dataGroupSize + 5 + 2 { // 5 byte(DataUnit?) + 2 byte(CRC)
            //print("payloadが足りない")
            //print(bytes.count, dataGroupSize, pesHeader.packetLength)
            return nil
        }
        self.payload = bytes
        var payloadLength = Int(dataGroupSize)
            - 1 // TMD + reserved
            - 3 // dataUnitLoopLength
            - (isManagedTime ? 5 : 0) // STM
        var array: [DataUnit] = []
        repeat {
            guard let dataUnit = try DataUnit(wrapper) else {
                //ToDo:
                if array.count != 0 {
                    //print("データユニット分離符号がない")
                    //printHexDumpForBytes(bytes: bytes)
                }
                try wrapper.skip(payloadLength - 1) // 1byte(length?)
                break
            }
            array.append(dataUnit)
            let sub = dataUnit.length // 5byte+可変長(DataUnit)
            payloadLength -= sub
        } while payloadLength > 0
        self.dataUnit = array
        self.CRC_16 = UInt16(try wrapper.get(num: 2))
        let headerLength = 3 + Int(pesDataPacketHeaderLength) // 3 byte(headerSizeまで) + 可変長分
        let wrapper_crc = ByteArray(pesHeader.payload)
        try wrapper_crc.skip(Int(headerLength))
        let crcBytes = try wrapper_crc.take(pesHeader.payload.count-headerLength-2) // 2 byte(CRC)
        let calcCRC16 = crc16(crcBytes)!
        if CRC_16 != calcCRC16 {
            // ToDo:
            fatalError("")
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
    public init?(_ wrapper: ByteArray) throws {
        self.unitSeparator = try wrapper.get()
        // データユニット分離符号: 0x1F
        if unitSeparator != 0x1F {
            return nil
        }
        self.dataUnitParameter = try wrapper.get()
        self.dataUnitSize = UInt32(try wrapper.get(num: 3)&0xFFFFFF)
        self.payload = try wrapper.take(Int(dataUnitSize))
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
extension DataUnit {
    public var length: Int {
        return 5+Int(dataUnitSize)
    }
}
