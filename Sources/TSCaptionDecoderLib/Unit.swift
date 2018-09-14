// 
//  Unit.swift
//  TSCaptionDecoderLib
//
//  Created by saga-dash on 2018/07/18.
//


import Foundation

public struct Unit: Codable {
    public let str: String
    public var eventId: String?
    public var serviceId: String?
    public var pts: UInt64?
    public let control: [Control]
    public init(str: String, control: [Control], eventId: String? = nil, serviceId: String? = nil, pts: UInt64? = nil) {
        self.str = str
        self.eventId = eventId
        self.serviceId = serviceId
        self.pts = pts
        self.control = control
    }
}
public struct Control: Codable {
    public let command: String
    public let code: ControlCode
    public let str: String?
    public let payload: [UInt8]
    public init(_ code: ControlCode, command: String? = nil, str: String? = nil, payload: [UInt8] = []) {
        self.command = command ?? "\(code)"
        self.code = code
        self.str = str
        self.payload = payload
    }
}
extension Control : CustomStringConvertible {
    public var description: String {
        return "Control(command: \(command)"
            + ", code: \(code)"
            + ", str: \(str ?? "")"
            + ", payload: \(payload.map({String(format: "0x%02x", $0)}).joined(separator: ","))"
            + ")"
    }
}
