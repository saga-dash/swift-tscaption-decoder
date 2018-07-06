// 
//  Caption.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/06.
//


import Foundation

// ARIB STD-B36
struct Caption {
    let header: TransportPacket
    let pesHeader: PacketizedElementaryStream
    let dataGroupId: UInt8                  //  6 uimsbf
    let dataGroupVersion: UInt8             //  2 bslbf
    let dataGroupLinkNumber: UInt8          //  8 uimsbf
    let lastDataGroupLinkNumber: UInt8      //  8 uimsbf
    let dataGroupSize: UInt16               // 16 uimsbf
    let TMD: UInt8                          //  2 uimsbf
    //let _reserved1: UInt8                 //  2 bslbf
    //let STM: UInt64                       // 36 uimsbf
    //let _reserved1: UInt8                 //  2 bslbf
    //let dataUnitLoopLength: UInt32        // 24 uimsbf
    let payload: [UInt8]                    //  n byte
    init?(_ data: Data) {
        self.header = TransportPacket(data)
        var bytes = header.payload
        if bytes[0] == 0x00 && bytes[1] == 0x0 && bytes[2] == 0x01 {
            self.pesHeader = PacketizedElementaryStream(data)
            bytes = pesHeader.payload
        } else {
            return nil
        }
        // ToDo: 定義どこ
        if bytes[0] != 0x80 && bytes[1] != 0x81 {
            print("字幕か文字スーパーである")
            return nil
        }
        // ToDo: 調査
        if bytes[1] != 0xFF {
            return nil
        }
        let headerSize = bytes[2]&0x0F
        // 3 byte(headerSizeまで), 5 byte(文字の最小サイズ？)
        if bytes.count < headerSize+3+5 {
            print("header分のpayloadが足りない")
            return nil
        }
        bytes = Array(bytes.suffix(bytes.count - numericCast(3+headerSize))) // 3 byte(headerSizeまで) + 可変長分
        self.dataGroupId = bytes[0]>>2
        self.dataGroupVersion = bytes[0]&0x03
        self.dataGroupLinkNumber = bytes[1]
        self.lastDataGroupLinkNumber = bytes[2]
        self.dataGroupSize = UInt16(bytes[3])<<8 | UInt16(bytes[4])
        self.TMD = bytes[5]>>6
        //self.STM = UInt64(bytes[5]&0x0F)<<32 | UInt64(bytes[6])<<24 | UInt64(bytes[7])<<16 | UInt64(bytes[8])<<8 | UInt64(bytes[9])
        //self.dataUnitLoopLength = UInt32(bytes[10])<<16 | UInt32(bytes[11])<<8 | UInt32(bytes[12])
        // ToDo: STM, dataUnitLoopLengthがない理由がわからない
        if bytes.count < dataGroupSize {
            print("payloadが足りない")
            return nil
        }
        bytes = Array(bytes.suffix(bytes.count - numericCast(9))) // 9 byte(Captionサイズ?)
        self.payload = Array(bytes.prefix(numericCast(dataGroupSize) - 4)) // 4 byte(dataGroupSizeからCaptionの終わりまで)
    }
}
extension Caption : CustomStringConvertible {
    var description: String {
        return "Caption(PID: \(String(format: "0x%04x", header.PID))"
            + ", dataGroupId: \(String(format: "0x%02x", dataGroupId))"
            + ", dataGroupSize: \(String(format: "0x%04x", dataGroupSize))"
            //+ ", dataUnitLoopLength: \(String(format: "0x%08x", dataUnitLoopLength))"
            + ")"
    }
}
extension Caption {
    var hexDump: [UInt8] {
        return pesHeader.payload
    }
}
