// 
//  ProgramAssociationTable.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation
import ByteArrayWrapper

// PAT
public struct ProgramAssociationTable {
    public let header: TransportPacket
    public let programAssociationSection: ProgramAssociationSection
    public let programs: [Program]
    public let CRC_32: UInt32    // 32 uimsbf
    public init?(_ data: Data, _ _header: TransportPacket? = nil) throws {
        self.header = try getHeader(data, _header)
        self.programAssociationSection = try ProgramAssociationSection(data, header)
        // 1 byte(ProgramAssociationSection終わりまで)
        if programAssociationSection.sectionLength - 1 > programAssociationSection.payload.count {
            return nil
        }
        let bytes = programAssociationSection.payload
        let wrapper = ByteArray(bytes)
        var programLength = Int(programAssociationSection.sectionLength
            - 5 // PAT(sessionLength以下の固定分)
            - 4 // CRC_32
        )
        var array: [Program] = []
        repeat {
            let index = wrapper.getIndex()
            do {
                let program = try Program(wrapper)
                array.append(program)
                let sub = program.length // 4byte
                programLength -= sub
            } catch {
                // 不正なprogramLength
                try wrapper.setIndex(index + programLength)
                break
            }
        } while programLength > 0
        self.programs = array
        self.CRC_32 = UInt32(try wrapper.get(num: 4))
    }
}
extension ProgramAssociationTable : CustomStringConvertible {
    public var description: String {
        return "PAT(networkId: \(String(format: "0x%02x", networkId))"
            + ", programs: \(programs)"
            + ", CRC_32: \(String(format: "0x%08x", CRC_32))"
            + ")"
    }
}
extension ProgramAssociationTable {
    public var hexDump: [UInt8] {
        return programAssociationSection.payload
    }
    public var networkId: UInt16 {
        guard let program = programs.first(where: { $0.programNumber == 0x00}) else {
            fatalError("Not Found networkId")
        }
        return program.PID
    }
}

public struct Program {
    public let programNumber: UInt16               // 16 uimsbf
    //public let _reserved1: UInt8                 //  3 bslbf
    public let PID: UInt16                         // 13 uimsbf
    public init(_ wrapper: ByteArray) throws {
        self.programNumber = UInt16(try wrapper.get(num: 2))
        self.PID = UInt16(try wrapper.get(num: 2)&0x1FFF)
    }
}
extension Program : CustomStringConvertible {
    public var description: String {
        return "{programNumber: \(String(format: "0x%04x", programNumber))"
            + ", PID: \(String(format: "0x%04x", PID))"
            + "}"
    }
}
extension Program {
    public var length: Int {
        return 4
    }
}
