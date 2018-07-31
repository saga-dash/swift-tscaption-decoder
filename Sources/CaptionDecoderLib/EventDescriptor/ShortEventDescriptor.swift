// 
//  ShortEventDescriptor.swift
//  CaptionDecoderLib
//
//  Created by saga-dash on 2018/08/01.
//


import Foundation


// ARIB STD-B10 第1部  図 6.2-12 短形式イベント記述子のデータ構造
public struct ShortEventDescriptor: EventDescriptor {
    public let descriptorTag: UInt8                 //  8 uimsbf
    public let descriptorLength: UInt8              //  8 uimsbf
    public let languageCode: UInt32                 // 24 uimsbf
    public let eventNameLength: UInt8               //  8 uimsbf
    public let eventName: [UInt8]                   //  n byte
    public let textLength: UInt8                    //  8 uimsbf
    public let text: [UInt8]                        //  n byte
    public init(_ bytes: [UInt8]) {
        self.descriptorTag = bytes[0]
        self.descriptorLength = bytes[1]
        self.languageCode = UInt32(bytes[2])<<16 | UInt32(bytes[3])<<8 | UInt32(bytes[4])
        self.eventNameLength = bytes[5]
        var index = 6+numericCast(eventNameLength)
        self.eventName = Array(bytes[6..<index])
        self.textLength = bytes[index]
        index += 1
        self.text = Array(bytes[index..<index+numericCast(textLength)])
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
        return ARIB8charDecode(eventName).str
    }
    public var textStr: String {
        return ARIB8charDecode(text).str
    }
}
