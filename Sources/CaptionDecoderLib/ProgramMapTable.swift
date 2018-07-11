// 
//  ProgramMapTable.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation

// PMT
public struct ProgramMapTable {
    public let header: TransportPacket
    public let programAssociationSection: ProgramAssociationSection
    //public let _reserved1                     //  3  bslbf
    public let PCR_PID: UInt16                  // 13  uimsbf
    //public let _reserved2                     //  4  bslbf
    public let programInfoLength: UInt16        // 12 uimsbf
    public let descriptor: [Descriptor]         // n byte
    public let stream: [Stream]                 // n byte
    public let CRC_32: UInt32                   // 32 uimsbf
    public init?(_ data: Data, _ _header: TransportPacket? = nil) {
        self.header = _header ?? TransportPacket(data)
        self.programAssociationSection = ProgramAssociationSection(data, header)
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
        var streamLength = programAssociationSection.sectionLength
            - 9 // PMT.sessionLength以下
            - numericCast(descriptorLengthConst) // descriptorの全体長
            - 4 // CRC_32
        var array: [Stream] = []
        repeat {
            let stream = Stream(bytes)
            array.append(stream)
            let sub = 5+Int(stream.esInfoLength) // 5byte+可変長(Stream)
            bytes = Array(bytes.suffix(bytes.count - sub))
            streamLength -= numericCast(sub)
        } while streamLength > 0
        self.stream = array
        self.CRC_32 = UInt32(bytes[0])<<24 | UInt32(bytes[1])<<16 | UInt32(bytes[2])<<8 | UInt32(bytes[3])
    }
}
extension ProgramMapTable : CustomStringConvertible {
    public var description: String {
        return "PMT(PCR_PID: \(String(format: "0x%04x", PCR_PID))"
            + ", descriptor: \(descriptor)"
            + ", stream: \(stream)"
            + ", CRC_32: \(String(format: "0x%08x", CRC_32))"
            + ")"
    }
}
extension ProgramMapTable {
    public var hexDump: [UInt8] {
        return programAssociationSection.payload
    }
}

public struct Descriptor {
    public let descriptorTag: UInt8               //  8 uimsbf
    public let descriptorLength: UInt8            //  8 uimsbf
    // ToDo: 追加
    public init(_ bytes: [UInt8]) {
        self.descriptorTag = bytes[0]
        self.descriptorLength = bytes[1]
    }
}
extension Descriptor : CustomStringConvertible {
    public var description: String {
        return "{descriptorTag: \(String(format: "0x%02x", descriptorTag))"
            + ", descriptorLength: \(String(format: "0x%02x", descriptorLength))"
            + "}"
    }
}
public struct Stream {
    public let streamType: UInt8                   //  8 uimsbf
    //public let _reserved1: UInt8                 //  3 bslbf
    public let elementaryPID: UInt16               // 13 uimsbf
    //public let _reserved2: UInt8                 //  4 bslbf
    public let esInfoLength: UInt16                // 12 uimsbf
    public let descriptor: [StreamDescriptor]        // 1 byte * esInfoLength
    public init(_ bytes: [UInt8]) {
        self.streamType = bytes[0]
        self.elementaryPID = UInt16(bytes[1]&0x1F)<<8 | UInt16(bytes[2])
        var esInfoLengthConst = UInt16(bytes[3]&0x0F)<<8 | UInt16(bytes[4])
        self.esInfoLength = esInfoLengthConst
        let sub = 5 // Stream
        var bytes = Array(bytes.suffix(bytes.count - sub))
        var array: [StreamDescriptor] = []
        repeat {
            let descriptor = StreamDescriptor(bytes)
            array.append(descriptor)
            let sub = 2+Int(descriptor.descriptorLength) // 2byte+可変長(StreamDescriptor)
            bytes = Array(bytes.suffix(bytes.count - sub))
            esInfoLengthConst -= numericCast(sub)
        } while esInfoLengthConst > 0
        self.descriptor = array
    }
}
extension Stream : CustomStringConvertible {
    public var description: String {
        return "{streamType: \(String(format: "0x%02x", streamType))"
            + ", elementaryPID: \(String(format: "0x%02x", elementaryPID))"
            + ", esInfoLength: \(String(format: "0x%02x", esInfoLength))"
            + ", descriptor: \(descriptor)"
            + "}"
    }
}
// ARIB STD-B10 第1部 図 6.2-17
public struct StreamDescriptor {
    public let descriptorTag: UInt8                //  8 uimsbf
    public let descriptorLength: UInt8             //  8 uimsbf
    public let componentTag: UInt8                 //  8 uimsbf
    public let payload: [UInt8]                    //  1 byte * n
    init(_ bytes: [UInt8]) {
        self.descriptorTag = bytes[0]
        self.descriptorLength = bytes[1]
        self.componentTag = bytes[2]
        // componentTag分
        if descriptorLength == 0x01 {
            self.payload = []
        } else {
            self.payload = Array(bytes[3..<Int(3+descriptorLength-1)]) // 3byte(StreamDescriptor) + descriptorLength -1byte(componentTag分)
        }
    }
}
extension StreamDescriptor : CustomStringConvertible {
    public var description: String {
        return "{descriptorTag: \(String(format: "0x%02x", descriptorTag))"
            + ", descriptorLength: \(String(format: "0x%02x", descriptorLength))"
            + ", componentTag: \(String(format: "0x%02x", componentTag))"
            + "}"
    }
}
