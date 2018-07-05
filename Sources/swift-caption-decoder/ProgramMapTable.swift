// 
//  ProgramMapTable.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation

// PMT
struct ProgramMapTable {
    let header: TransportPacket
    let programAssociationSection: ProgramAssociationSection
    //let _reserved1                    //  3  bslbf
    let PCR_PID: UInt16                 // 13  uimsbf
    //let _reserved2                    //  4  bslbf
    let programInfoLength: UInt16       // 12 uimsbf
    let descriptor: [Descriptor]          // n byte
    let stream: [Stream]                // n byte
    let CRC_32: UInt32    // 32 uimsbf
    init?(_ data: Data) {
        self.header = TransportPacket(data)
        self.programAssociationSection = ProgramAssociationSection(data)
        var bytes = programAssociationSection.payload
        self.PCR_PID = UInt16(bytes[0]&0x1F)<<8 | UInt16(bytes[1])
        // -- Descriptor
        let descriptorLengthConst = UInt16(bytes[2]&0x0F)<<8 | UInt16(bytes[3])
        self.programInfoLength = descriptorLengthConst
        var descriptorLength = descriptorLengthConst
        bytes = Array(bytes.suffix(bytes.count - 4)) // 4byte(PMT定義分のみ)
        var descriptorArray: [Descriptor] = []
        repeat {
            let descriptor = Descriptor(bytes)
            descriptorArray.append(descriptor)
            let sub = 2+Int(descriptor.descriptorLength) // 2byte+可変長(Descriptor)
            bytes = Array(bytes.suffix(bytes.count - sub))
            descriptorLength -= numericCast(sub)
        } while descriptorLength > 0
        self.descriptor = descriptorArray
        // sectionLengthより前のデータ
        // 4byte: header
        // 1byte: pointer_field
        // 3byte: PMT.sessionLengthより前
        if (programAssociationSection.sectionLength > data.count - 4 - 1 - 3) {
            // payloadのデータ不足
            return nil
        }
        // -- Stream
        var programInfoLength = programAssociationSection.sectionLength
            - 9 // PMT.sessionLength以下
            - numericCast(descriptorLengthConst) // descriptorの全体長
            - 4 // CRC_32
        var array: [Stream] = []
        repeat {
            let stream = Stream(bytes)
            array.append(stream)
            let sub = 5+Int(stream.esInfoLength) // 5byte+可変長(Stream)
            bytes = Array(bytes.suffix(bytes.count - sub))
            programInfoLength -= numericCast(sub)
        } while programInfoLength > 0
        self.stream = array
        self.CRC_32 = UInt32(bytes[0])<<24 | UInt32(bytes[1])<<16 | UInt32(bytes[2])<<8 | UInt32(bytes[3])
    }
}
extension ProgramMapTable : CustomStringConvertible {
    var description: String {
        return "PMT(PCR_PID: \(String(format: "0x%04x", PCR_PID))"
            + ", descriptor: \(descriptor)"
            + ", stream: \(stream)"
            + ", CRC_32: \(String(format: "0x%08x", CRC_32))"
            + ")"
    }
}
extension ProgramMapTable {
    var hexDump: [UInt8] {
        return programAssociationSection.payload
    }
}

struct Descriptor {
    let descriptorTag: UInt8               //  8 uimsbf
    let descriptorLength: UInt8            //  8 uimsbf
    // ToDo: 追加
    init(_ bytes: [UInt8]) {
        self.descriptorTag = bytes[0]
        self.descriptorLength = bytes[1]
    }
}
extension Descriptor : CustomStringConvertible {
    var description: String {
        return "descriptorTag: \(String(format: "0x%02x", descriptorTag))"
            + ", descriptorLength: \(String(format: "0x%02x", descriptorLength))"
    }
}
struct Stream {
    let streamId: UInt8                     //  8 uimsbf
    //let _reserved1: UInt8                 //  3 bslbf
    let elementaryPID: UInt16               // 13 uimsbf
    //let _reserved2: UInt8                 //  4 bslbf
    let esInfoLength: UInt16                // 12 uimsbf
    // ToDo: 追加                            // 8 byte * esInfoLength
    init(_ bytes: [UInt8]) {
        self.streamId = bytes[0]
        self.elementaryPID = UInt16(bytes[1]&0x1F)<<8 | UInt16(bytes[2])
        self.esInfoLength = UInt16(bytes[3]&0x0F)<<8 | UInt16(bytes[4])
    }
}
extension Stream : CustomStringConvertible {
    var description: String {
        return "streamId: \(String(format: "0x%02x", streamId))"
            + ", elementaryPID: \(String(format: "0x%02x", elementaryPID))"
            + ", esInfoLength: \(String(format: "0x%02x", esInfoLength))"
    }
}
