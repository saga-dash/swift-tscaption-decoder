// 
//  Unit.swift
//  CaptionDecoderLib
//
//  Created by saga-dash on 2018/07/18.
//


import Foundation

public struct Unit {
    public let str: String
    public var eventId: UInt16
    public var serviceId: String
    public let control: [Control]
    public init(str: String, control: [Control], eventId: UInt16 = 0xFFFF, serviceId: String = "") {
        self.str = str
        self.eventId = eventId
        self.serviceId = serviceId
        self.control = control
    }
}
public struct Control {
    public let command: String
    public let code: ControlCode
    public let payload: [UInt8]
    public init(_ code: ControlCode, command: String? = nil, payload: [UInt8] = []) {
        self.command = command ?? "\(code)"
        self.code = code
        self.payload = payload
    }
}
extension Control : CustomStringConvertible {
    public var description: String {
        return "Control(command: \(command)"
            + ", code: \(code)"
            + ", payload: \(payload.map({String(format: "0x%02x", $0)}).joined(separator: ","))"
            + ")"
    }
}
