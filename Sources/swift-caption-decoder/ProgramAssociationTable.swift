// 
//  ProgramAssociationTable.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation

// PAT
struct ProgramAssociationTable {
    let header: TransportPacket
    let programAssociationSection: ProgramAssociationSection
    let programs: [Program]
    let CRC_32: UInt32    // 32 uimsbf
    init(_ data: Data) {
        self.header = TransportPacket(data)
        self.programAssociationSection = ProgramAssociationSection(data)
        var bytes = programAssociationSection.payload
        let payloadLength = programAssociationSection.sectionLength
            - 5 // PAT(sessionLength以下の固定分)
            - 4 // CRC_32
        var programLength = payloadLength
        var array: [Program] = []
        repeat {
            array.append(Program(bytes))
            let sub = 4 // 4byte(Program)
            bytes = Array(bytes.suffix(bytes.count - sub))
            programLength -= numericCast(sub)
        } while programLength > 0
        self.programs = array
        self.CRC_32 = UInt32(bytes[0])<<24 | UInt32(bytes[1])<<16 | UInt32(bytes[2])<<8 | UInt32(bytes[3])
        assert(programAssociationSection.sectionLength < LENGTH - numericCast(payloadLength), "ToDo: PATが188Byteを超えた場合の対処")
    }
}
extension ProgramAssociationTable : CustomStringConvertible {
    var description: String {
        return "PAT(networkId: \(String(format: "0x%02x", networkId))"
            + ", programs: \(programs)"
            + ", CRC_32: \(String(format: "0x%08x", CRC_32))"
            + ")"
    }
}
extension ProgramAssociationTable {
    var hexDump: [UInt8] {
        return programAssociationSection.payload
    }
    var networkId: UInt16 {
        guard let program = programs.first(where: { $0.programNumber == 0x00}) else {
            fatalError("Not Found networkId")
        }
        return program.PID
    }
}

struct Program {
    let programNumber: UInt16               // 16 uimsbf
    //let _reserved1: UInt8                 //  3 bslbf
    let PID: UInt16                         // 13 uimsbf
    init(_ bytes: [UInt8]) {
        self.programNumber = UInt16(bytes[0])<<8 | UInt16(bytes[1])
        self.PID = UInt16(bytes[2]&0x1F)<<8 | UInt16(bytes[3])
    }
}
extension Program : CustomStringConvertible {
    var description: String {
        return "{programNumber: \(String(format: "0x%04x", programNumber))"
            + ", PID: \(String(format: "0x%04x", PID))"
            + "}"
    }
}
