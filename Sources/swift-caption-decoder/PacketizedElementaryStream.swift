// 
//  PacketizedElementaryStream.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/06.
//


import Foundation

// PES http://www.nhk.or.jp/strl/publica/bt/en/le0011.pdf
struct PacketizedElementaryStream {
    let header: TransportPacket
    let packetStartCodePrefix: UInt32       // 24 bit
    let streamId: UInt8                     //  8 bit
    let packetLength: UInt16                // 16 bit
    // ToDo: 追加                            // 16 bit
    let pesHeaderLength: UInt8              //  8 bit
    // ToDo: 追加
    let payload: [UInt8]                    //  n byte
    init(_ data: Data) {
        self.header = TransportPacket(data)
        var bytes = header.payload
        self.packetStartCodePrefix = UInt32(bytes[0])<<16 | UInt32(bytes[1])<<8 | UInt32(bytes[2])
        self.streamId = bytes[3]
        self.packetLength = UInt16(bytes[4])<<8 | UInt16(bytes[5])
        self.pesHeaderLength = bytes[8]
        self.payload = Array(bytes.suffix(bytes.count - Int(9+pesHeaderLength))) // 9(pesHeaderLengthまで) + n byte(可変長)
    }
}
extension PacketizedElementaryStream : CustomStringConvertible {
    var description: String {
        return "PacketizedElementaryStream(PID: \(String(format: "0x%04x", header.PID))"
            + ", streamId: \(String(format: "0x%02x", streamId))"
            + ", packetLength: \(String(format: "0x%04x", packetLength))"
            + ", pesHeaderLength: \(String(format: "0x%02x", pesHeaderLength))"
            + ")"
    }
}
extension PacketizedElementaryStream {
    var hexDump: [UInt8] {
        return header.payload
    }
}
