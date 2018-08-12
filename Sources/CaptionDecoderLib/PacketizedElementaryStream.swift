// 
//  PacketizedElementaryStream.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/06.
//


import Foundation
import ByteArrayWrapper

// PES http://www.nhk.or.jp/strl/publica/bt/en/le0011.pdf
public struct PacketizedElementaryStream {
    public let header: TransportPacket
    public let packetStartCodePrefix: UInt32       // 24 bit
    public let streamId: UInt8                     //  8 bit
    public let packetLength: UInt16                // 16 bit
    // ToDo: 追加                                   // 16 bit
    //public let pesHeaderLength: UInt8              //  8 bit
    // ToDo: 追加
    public let payload: [UInt8]                    //  n byte
    public init?(_ data: Data, _ _header: TransportPacket? = nil) throws {
        self.header = try getHeader(data, _header, isPes: true)
        let bytes = header.payload
        let wrapper = ByteArray(bytes)
        self.packetStartCodePrefix = UInt32(try wrapper.get(num: 3))
        self.streamId = try wrapper.get()
        self.packetLength = UInt16(try wrapper.get(num: 2))
        if packetLength > wrapper.count { // 6 byte(packetLengthまで)
            return nil
        }
        // ARIB STD-B24 第三編 第5章 独立 PES 伝送方式
        // ToDo: private_stream_1, private_stream_2についてheaderの言及を探す
        if streamId == 0xBD {
            // private_stream_1
            try wrapper.skip(2)
            let pesHeaderLength = Int(try wrapper.get())
            try wrapper.skip(pesHeaderLength)
            self.payload = try wrapper.take() // n byte(可変長)
        } else if streamId == 0xBF {
            // private_stream_2
            self.payload = try wrapper.take() // n byte(可変長)
        } else {
            self.payload = []
            fatalError("まだだよ。streamId: \(String(format: "0x%02x", streamId))")
        }
    }
}
extension PacketizedElementaryStream : CustomStringConvertible {
    public var description: String {
        return "PacketizedElementaryStream(PID: \(String(format: "0x%04x", header.PID))"
            + ", streamId: \(String(format: "0x%02x", streamId))"
            + ", packetLength: \(String(format: "0x%04x", packetLength))"
            + ")"
    }
}
extension PacketizedElementaryStream {
    public var hexDump: [UInt8] {
        return header.payload
    }
}
