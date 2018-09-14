// 
//  PacketizedElementaryStream.swift
//  TSCaptionDecoderLib
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
    // ToDo: 追加                                   // 8 bit
    public let ptsdtsIndicator: UInt8              // 2 bit
    // ToDo: 追加                                   // 6 bit
    public let pesHeaderLength: UInt8              //  8 bit
    public let pts: [UInt8]?                        // 40 bit
    public let dts: [UInt8]?                        // 40 bit
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
            let flag = (try wrapper.get()&0xC0)>>6 == 0x02
            self.ptsdtsIndicator = (try wrapper.get()&0xC0)>>6
            self.pesHeaderLength = try wrapper.get()
            var headerLength = Int(pesHeaderLength)
            if ptsdtsIndicator&0x02 == 0x02 && flag {
                self.pts = try wrapper.take(5)
                headerLength -= 5
                if ptsdtsIndicator&0x01 == 0x01 {
                    self.dts = try wrapper.take(5)
                    headerLength -= 5
                } else {
                    self.dts = nil
                }
            } else {
                self.pts = nil
                self.dts = nil
            }
            try wrapper.skip(headerLength)
            self.payload = try wrapper.take() // n byte(可変長)
        } else if streamId == 0xBF {
            // private_stream_2
            self.ptsdtsIndicator = 0
            self.pesHeaderLength = 0
            self.pts = nil
            self.dts = nil
            self.payload = try wrapper.take() // n byte(可変長)
        } else {
            self.ptsdtsIndicator = 0
            self.pesHeaderLength = 0
            self.pts = nil
            self.dts = nil
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
            + ", pesHeaderLength: \(String(format: "0x%02x", pesHeaderLength))"
            + ", pts: \(ptsStr)"
            + ", dts: \(dtsStr)"
            + ")"
    }
}
extension PacketizedElementaryStream {
    public var hexDump: [UInt8] {
        return header.payload
    }
    public var ptsStr: String {
        guard let pts = pts else {
            return ""
        }
        return convertTimeStamp(pickTimeStamp(pts)) ?? ""
    }
    public var dtsStr: String {
        guard let dts = dts else {
            return ""
        }
        return convertTimeStamp(pickTimeStamp(dts)) ?? ""
    }
}
