// 
//  TransportPacket.swift
//  TSCaptionDecoderLib
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation
import ByteArrayWrapper

public struct TransportPacket {
    public let data: Data
    public let syncByte: UInt8                      //  8  bslbf
    public let transportErrorIndicator: UInt8       //  1  bslbf
    public let payloadUnitStartIndicator: UInt8     //  1  bslbf
    public let transportPriority: UInt8             //  1  bslbf
    public let PID: UInt16                          // 13  uimsbf
    public let transportScramblingControl: UInt8    //  2  bslbf
    public let adaptationFieldControl: UInt8        //  2  bslbf
    public let continuityCounter: UInt8             //  4  uimsbf
    let isPes: Bool
    public init(_ data: Data, isPes: Bool = false) throws {
        self.data = data
        let bytes = [UInt8](data)
        let wrapper = ByteArray(bytes)
        self.syncByte = try wrapper.get()
        self.transportErrorIndicator = (try wrapper.get(doMove: false)&0x80)>>7
        self.payloadUnitStartIndicator = (try wrapper.get(doMove: false)&0x40)>>6
        self.transportPriority = (try wrapper.get(doMove: false)&0x20)>>5
        self.PID = UInt16(try wrapper.get(num: 2)&0x1FFF)
        self.transportScramblingControl = (try wrapper.get(doMove: false)&0xC0)>>6
        self.adaptationFieldControl = (try wrapper.get(doMove: false)&0x30)>>4
        self.continuityCounter = (try wrapper.get()&0x0F)
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
        return adaptationField==nil && (isPes || payloadUnitStartIndicator != 0x01)
    }
    public var payload: [UInt8] {
        let bytes = [UInt8](data)
        return Array(bytes.suffix(bytes.count - self.length)) // HeaderLength + Payload = 188
    }
    public var length: Int {
        let headerLength = 4 // Header
            + (numericCast(adaptationField?.adaptationFieldLength ?? 0)) // AdaptationFieldLength
            + (noPointerField ? 0 : 1) // pointer_field
        return Int(headerLength)
    }
    public var enoughHeaderLength: Bool {
        if let adaptationField = self.adaptationField {
            if numericCast(adaptationField.adaptationFieldLength) + 4 > self.data.count {
                return false
            }
        }
        return true
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
            + ", length: \(String(format: "0x%02x", length))"
            + ", continuityCounter: \(String(format: "0x%02x", continuityCounter))"
            + ")"
    }
}
