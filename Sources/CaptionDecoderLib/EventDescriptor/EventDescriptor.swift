// 
//  EventDescriptor.swift
//  CaptionDecoderLib
//
//  Created by saga-dash on 2018/07/31.
//


import Foundation


// ARIB STD-B10 第1部  図 6.2-*
public protocol EventDescriptor {
    var descriptorTag: UInt8 { get }                 //  8 uimsbf
    var descriptorLength: UInt8 { get }              //  8 uimsbf
    init(_ bytes: [UInt8])
    var description: String { get }
}
extension EventDescriptor {
    var length: Int {
        // 2 byte + descriptorLength
        return 2 + Int(descriptorLength)
    }
}

public struct UnhandledDescriptor: EventDescriptor {
    public var descriptorTag: UInt8
    public var descriptorLength: UInt8
    public init(_ bytes: [UInt8]) {
        self.descriptorTag = bytes[0]
        self.descriptorLength = bytes[1]
        self.name = "Unhandled"
    }
    public var name: String
    public init(_ bytes: [UInt8], _ name: String) {
        self.init(bytes)
        self.name = name
    }
}
extension UnhandledDescriptor : CustomStringConvertible {
    public var description: String {
        return "\(name)(descriptorTag: \(String(format: "0x%02x", descriptorTag))"
            + ", descriptorLength: \(String(format: "0x%02x", descriptorLength))"
            + ")"
    }
}


func convertEventDescriptor(_ bytes: [UInt8]) -> EventDescriptor? {
    switch bytes[0] {
    case 0x4D:
        return ShortEventDescriptor(bytes)
    case 0x4E:
        return UnhandledDescriptor(bytes, "ExtensionEvent")
    case 0x50:
        return UnhandledDescriptor(bytes, "Component")
    case 0x54:
        return UnhandledDescriptor(bytes, "Content")
    case 0xC1:
        return UnhandledDescriptor(bytes, "DigitalCopyControl")
    case 0xC4:
        return UnhandledDescriptor(bytes, "Audio")
    case 0xC7:
        return UnhandledDescriptor(bytes, "DataContents")
    case 0xD6:
        return UnhandledDescriptor(bytes, "EventGroup")
    default:
        return UnhandledDescriptor(bytes)
    }
}
