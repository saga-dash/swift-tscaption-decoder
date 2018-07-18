// 
//  ProgramAssociationSection.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation

public struct ProgramAssociationSection {
    public let header: TransportPacket
    public let tableId: UInt8                      //  8  uimsbf
    public let sectionSyntaxIndicator: UInt8       //  1  bslbf
    //'0'                                          //  1  bslbf
    //public let _reserved1: UInt8                 //  2  bslbf
    public let sectionLength: UInt16               // 12  uimsbf
    public let serviceId: UInt16                   // 16  uimsbf
    //public let _reserved2: UInt8                 //  2  bslbf
    public let versionNumber: UInt8                //  5  uimsbf
    public let currentNextIndicator: UInt8         //  1  bslbf
    public let sectionNumber: UInt8                //  8  uimsbf
    public let lastSectionNumber: UInt8            //  8  uimsbf
    public let payload: [UInt8]                    //  n  byte
    public init(_ data: Data, _ _header: TransportPacket? = nil) {
        self.header = _header ?? TransportPacket(data)
        let bytes = header.payload
        self.tableId = bytes[0]
        self.sectionSyntaxIndicator = (bytes[1]&0x80)>>7
        self.sectionLength = UInt16(bytes[1]&0x0F)<<8 | UInt16(bytes[2])
        self.serviceId = UInt16(bytes[3])<<8 | UInt16(bytes[4])
        self.versionNumber = (bytes[5]&0x3E)>>1
        self.currentNextIndicator = (bytes[5]&0x01)
        self.sectionNumber = (bytes[6])
        self.lastSectionNumber = (bytes[7])
        self.payload = Array(bytes.suffix(bytes.count - Int(8))) // 8byte(固定長)
    }
}
extension ProgramAssociationSection : CustomStringConvertible {
    public var description: String {
        return "ProgramAssociationSection(tableId: \(String(format: "0x%02x", tableId))"
            + ", sectionSyntaxIndicator: \(sectionSyntaxIndicator)"
            + ", sectionLength: \(String(format: "0x%04x", sectionLength))"
            + ", serviceId: \(String(format: "0x%04x", serviceId))"
            + ", versionNumber: \(String(format: "0x%02x", versionNumber))"
            + ", currentNextIndicator: \(currentNextIndicator)"
            + ", sectionNumber: \(String(format: "0x%02x", sectionNumber))"
            + ", lastSectionNumber: \(String(format: "0x%02x", lastSectionNumber))"
            + ")"
    }
}
extension ProgramAssociationSection {
    public var hexDump: [UInt8] {
        return header.payload
    }
}
