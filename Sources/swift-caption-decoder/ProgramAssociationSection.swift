// 
//  ProgramAssociationSection.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation

struct ProgramAssociationSection {
    let header: TransportPacket
    let tableId: UInt8                      //  8  uimsbf
    let sectionSyntaxIndicator: UInt8       //  1  bslbf
    //'0'                                   //  1  bslbf
    //let _reserved1: UInt8                 //  2  bslbf
    let sectionLength: UInt16               // 12  uimsbf
    let transportStreamId: UInt16           // 16  uimsbf
    //let _reserved2: UInt8                 //  2  bslbf
    let versionNumber: UInt8                //  5  uimsbf
    let currentNextIndicator: UInt8         //  1  bslbf
    let sectionNumber: UInt8                //  8  uimsbf
    let lastSectionNumber: UInt8            //  8  uimsbf
    let payload: [UInt8]                    //  n  byte
    init(_ data: Data) {
        self.header = TransportPacket(data)
        let bytes = header.payload
        self.tableId = bytes[0]
        self.sectionSyntaxIndicator = (bytes[1]&0x80)>>7
        self.sectionLength = UInt16(bytes[1]&0x0F)<<8 | UInt16(bytes[2])
        self.transportStreamId = UInt16(bytes[3])<<8 | UInt16(bytes[4])
        self.versionNumber = (bytes[5]&0x3E)>>1
        self.currentNextIndicator = (bytes[5]&0x01)
        self.sectionNumber = (bytes[6])
        self.lastSectionNumber = (bytes[7])
        self.payload = Array(bytes.suffix(bytes.count - Int(8))) // 8byte(固定長)
    }
}
extension ProgramAssociationSection : CustomStringConvertible {
    var description: String {
        return "ProgramAssociationSection(tableId: \(String(format: "0x%02x", tableId))"
            + ", sectionSyntaxIndicator: \(sectionSyntaxIndicator)"
            + ", sectionLength: \(String(format: "0x%04x", sectionLength))"
            + ", transportStreamId: \(String(format: "0x%04x", transportStreamId))"
            + ", versionNumber: \(String(format: "0x%02x", versionNumber))"
            + ", currentNextIndicator: \(currentNextIndicator)"
            + ", sectionNumber: \(String(format: "0x%02x", sectionNumber))"
            + ", lastSectionNumber: \(String(format: "0x%02x", lastSectionNumber))"
            + ")"
    }
}
extension ProgramAssociationSection {
    var hexDump: [UInt8] {
        return header.payload
    }
}
