// 
//  TransportPacket.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation

struct TransportPacket {
    let syncByte: UInt8                      //  8  bslbf
    let transportErrorIndicator: UInt8       //  1  bslbf
    let payloadUnitStartIndicator: UInt8     //  1  bslbf
    let transportPriority: UInt8             //  1  bslbf
    let PID: UInt16                          // 13  uimsbf
    let transportScramblingControl: UInt8    //  2  bslbf
    let adaptationFieldControl: UInt8        //  2  bslbf
    let continuityCounter: UInt8             //  4  uimsbf
    let adaptationField: AdaptationField?    //  n  byte
    let payload: [UInt8]                     //  n  byte
    init(_ data: Data) {
        let bytes = [UInt8](data)
        self.syncByte = bytes[0]
        self.transportErrorIndicator = (bytes[1]&0x80)>>7
        self.payloadUnitStartIndicator = (bytes[1]&0x40)>>6
        self.transportPriority = (bytes[1]&0x20)>>5
        self.PID = UInt16(bytes[1]&0x1F)<<8 | UInt16(bytes[2])
        self.transportScramblingControl = (bytes[3]&0xC0)>>6
        self.adaptationFieldControl = (bytes[3]&0x30)>>4
        self.continuityCounter = (bytes[3]&0x0F)
        self.adaptationField = (adaptationFieldControl&0x02)>>1 == 1 ? AdaptationField(data) : nil
        let isPes = bytes[4] == 0x00 && bytes[5] == 0x00 && bytes[6] == 0x01
        let headerLength = 4 // Header
            + (adaptationField?.adaptationFieldLength ?? 0) // AdaptationFieldLength
            + (isPes ? 0 : 1) // pointer_field
        self.payload = Array(bytes.suffix(bytes.count - Int(headerLength))) // HeaderLength + Payload = 188
    }
}
extension TransportPacket {
    var adaptationFlag: UInt8 {
        return (adaptationFieldControl&0x02)>>1
    }
    var payloadFlag: UInt8 {
        return (adaptationFieldControl&0x01)
    }
}
struct AdaptationField {
    let adaptationFieldLength: UInt8
    //var nonDiscontinuityIndicator: UInt8
    //var randomAccessIndicator: UInt8
    //var elementaryStreamPriorityIndicator: UInt8
    //var flag: UInt8
    //var optionField:
    //var stuffingByte:
    init(_ data: Data) {
        let bytes = [UInt8](data)
        let offset = 4  // TransportPacket
        self.adaptationFieldLength = bytes[offset + 0]
    }
}
extension TransportPacket : CustomStringConvertible {
    var description: String {
        return "TransportPacket(PID: \(String(format: "0x%05x", PID))"
            + ", syncByte: \(String(format: "0x%02x", syncByte))"
            + ", transportErrorIndicator: \(transportErrorIndicator)"
            + ", payloadUnitStartIndicator: \(payloadUnitStartIndicator)"
            + ", transportPriority: \(transportPriority)"
            + ", transportScramblingControl: \(String(format: "0x%x", transportScramblingControl))"
            + ", (adaptationFlag: \(adaptationFlag)"
            + ", payloadFlag: \(payloadFlag))"
            + ", continuityCounter: \(String(format: "0x%02x", continuityCounter))"
            + ")"
    }
}
