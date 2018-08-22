// 
//  ShortEventDescriptor.swift
//  TSCaptionDecoderLib
//
//  Created by saga-dash on 2018/08/01.
//


import Foundation
import ByteArrayWrapper

// ARIB STD-B10 第1部  図 6.2-12 短形式イベント記述子のデータ構造
public struct ShortEventDescriptor: EventDescriptor {
    public let descriptorTag: UInt8                 //  8 uimsbf
    public let descriptorLength: UInt8              //  8 uimsbf
    public let languageCode: UInt32                 // 24 uimsbf
    public let eventNameLength: UInt8               //  8 uimsbf
    public let eventName: [UInt8]                   //  n byte
    public let textLength: UInt8                    //  8 uimsbf
    public let text: [UInt8]                        //  n byte
    public init(_ wrapper: ByteArray) throws {
        self.descriptorTag = try wrapper.get()
        self.descriptorLength = try wrapper.get()
        self.languageCode = UInt32(try wrapper.get(num: 3))
        self.eventNameLength = try wrapper.get()
        self.eventName = try wrapper.take(Int(eventNameLength))
        self.textLength = try wrapper.get()
        self.text = try wrapper.take(Int(textLength))
    }
}
extension ShortEventDescriptor : CustomStringConvertible {
    public var description: String {
        return "ShortEvent(descriptorTag: \(String(format: "0x%02x", descriptorTag))"
            + ", descriptorLength: \(String(format: "0x%02x", descriptorLength))"
            + ", languageCode: \(String(format: "0x%06x", languageCode))"
            + ", eventNameLength: \(String(format: "0x%02x", eventNameLength))(\(eventStr))"
            + ", textLength: \(String(format: "0x%02x", textLength))(\(textStr))"
            + ")"
    }
    public var eventStr: String {
        guard let str = try? ARIB8charDecode(eventName).str else {
            return ""
        }
        return str
    }
    public var textStr: String {
        guard let str = try? ARIB8charDecode(text).str else {
            return ""
        }
        return str
    }
}
