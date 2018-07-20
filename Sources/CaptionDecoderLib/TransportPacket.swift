// 
//  TransportPacket.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation

public struct TransportPacket {
    let data: Data
    public let syncByte: UInt8                      //  8  bslbf
    public let transportErrorIndicator: UInt8       //  1  bslbf
    public let payloadUnitStartIndicator: UInt8     //  1  bslbf
    public let transportPriority: UInt8             //  1  bslbf
    public let PID: UInt16                          // 13  uimsbf
    public let transportScramblingControl: UInt8    //  2  bslbf
    public let adaptationFieldControl: UInt8        //  2  bslbf
    public let continuityCounter: UInt8             //  4  uimsbf
    let isPes: Bool
    public init(_ data: Data, isPes: Bool = false) {
        self.data = data
        let bytes = [UInt8](data)
        self.syncByte = bytes[0]
        self.transportErrorIndicator = (bytes[1]&0x80)>>7
        self.payloadUnitStartIndicator = (bytes[1]&0x40)>>6
        self.transportPriority = (bytes[1]&0x20)>>5
        self.PID = UInt16(bytes[1]&0x1F)<<8 | UInt16(bytes[2])
        self.transportScramblingControl = (bytes[3]&0xC0)>>6
        self.adaptationFieldControl = (bytes[3]&0x30)>>4
        self.continuityCounter = (bytes[3]&0x0F)
        self.isPes = isPes
    }
}
extension TransportPacket {
    public var adaptationFlag: UInt8 {
        return (adaptationFieldControl&0x02)>>1
    }
    public var payloadFlag: UInt8 {
        return (adaptationFieldControl&0x01)
    }
    public var adaptationField: AdaptationField? {
        return adaptationFlag == 1 ? AdaptationField(data) : nil
    }
    var noPointerField: Bool {
        return adaptationField==nil && isPes
    }
    public var payload: [UInt8] {
        let bytes = [UInt8](data)
        let headerLength = 4 // Header
            + (adaptationField?.adaptationFieldLength ?? 0) // AdaptationFieldLength
            + (noPointerField ? 0 : 1) // pointer_field
        return Array(bytes.suffix(bytes.count - Int(headerLength))) // HeaderLength + Payload = 188
    }
    public var valid: Bool {
        return !(adaptationFlag == 0 && payloadUnitStartIndicator == 0x01 && data[4] != 0x00)
    }
}
public struct AdaptationField {
    public let adaptationFieldLength: UInt8
    //public var nonDiscontinuityIndicator: UInt8
    //public var randomAccessIndicator: UInt8
    //public var elementaryStreamPriorityIndicator: UInt8
    //public var flag: UInt8
    //public var optionField:
    //public var stuffingByte:
    public init(_ data: Data) {
        let bytes = [UInt8](data)
        let offset = 4  // TransportPacket
        self.adaptationFieldLength = bytes[offset + 0]
    }
}
extension TransportPacket : CustomStringConvertible {
    public var description: String {
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
