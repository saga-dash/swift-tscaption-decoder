// 
//  ProgramMapTable.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation
import ByteArrayWrapper

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
    public init?(_ data: Data, _ _header: TransportPacket? = nil) throws {
        self.header = try getHeader(data, _header)
        self.programAssociationSection = try ProgramAssociationSection(data, header)
        if programAssociationSection.sectionLength - 1 > programAssociationSection.payload.count {
            return nil
        }
        let bytes = programAssociationSection.payload
        let wrapper = ByteArray(bytes)
        self.PCR_PID = UInt16(try wrapper.get(num: 2)&0x1FFF)
        // -- Descriptor
        self.programInfoLength = UInt16(try wrapper.get(num: 2)&0x0FFF)
        var descriptorLength = Int(programInfoLength)
        var descriptorArray: [Descriptor] = []
        repeat {
            let index = wrapper.getIndex()
            do {
                let descriptor = try Descriptor(wrapper)
                descriptorArray.append(descriptor)
                let sub = descriptor.length // 2byte+可変長(Descriptor)
                descriptorLength -= sub
            } catch {
                // 不正なdescriptorLength
                try wrapper.setIndex(index + descriptorLength)
                break
            }
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
        var streamLength = Int(programAssociationSection.sectionLength)
            - 9 // PMT.sessionLength以下
            - Int(programInfoLength) // descriptorの全体長
            - 4 // CRC_32
        var array: [Stream] = []
        repeat {
            let index = wrapper.getIndex()
            do {
                let stream = try Stream(wrapper)
                array.append(stream)
                let sub = stream.length // 5byte+可変長(Stream)
                streamLength -= sub
            } catch {
                // 不正なstreamLength
                try wrapper.setIndex(index + streamLength)
                break
            }
        } while streamLength > 0
        self.stream = array
        self.CRC_32 = UInt32(try wrapper.get(num: 4))
    }
}
extension ProgramMapTable : CustomStringConvertible {
    public var description: String {
        return "PMT(PCR_PID: \(String(format: "0x%04x", PCR_PID))"
            + ", programInfoLength: \(String(format: "0x%04x", programInfoLength))"
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
    public init(_ wrapper: ByteArray) throws {
        self.descriptorTag = try wrapper.get()
        self.descriptorLength = try wrapper.get()
        try wrapper.skip(Int(descriptorLength))
    }
}
extension Descriptor : CustomStringConvertible {
    public var description: String {
        return "{descriptorTag: \(String(format: "0x%02x", descriptorTag))"
            + ", descriptorLength: \(String(format: "0x%02x", descriptorLength))"
            + "}"
    }
}
extension Descriptor {
    public var length: Int {
        return 2+Int(descriptorLength)
    }
}
public struct Stream {
    public let streamType: UInt8                   //  8 uimsbf
    //public let _reserved1: UInt8                 //  3 bslbf
    public let elementaryPID: UInt16               // 13 uimsbf
    //public let _reserved2: UInt8                 //  4 bslbf
    public let esInfoLength: UInt16                // 12 uimsbf
    public let descriptor: [StreamDescriptor]        // 1 byte * esInfoLength
    public init(_ wrapper: ByteArray) throws {
        self.streamType = try wrapper.get()
        self.elementaryPID = UInt16(try wrapper.get(num: 2)&0x1FFF)
        self.esInfoLength = UInt16(try wrapper.get(num: 2)&0x0FFF)
        if wrapper.count < esInfoLength {
            throw ByteArrayError.outOfRange()
        }
        var descriptorLength = Int(esInfoLength)
        var array: [StreamDescriptor] = []
        repeat {
            let index = wrapper.getIndex()
            do {
                let descriptor = try StreamDescriptor(wrapper)
                array.append(descriptor)
                let sub = descriptor.length // 2byte+可変長(StreamDescriptor)
                descriptorLength -= sub
            } catch {
                // 不正なesInfoLength
                try wrapper.setIndex(index + descriptorLength)
                break
            }
        } while descriptorLength > 0
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
extension Stream {
    public var length: Int {
        return 5+Int(esInfoLength)
    }
}
// ARIB STD-B10 第1部 図 6.2-17
public struct StreamDescriptor {
    public let descriptorTag: UInt8                //  8 uimsbf
    public let descriptorLength: UInt8             //  8 uimsbf
    public let componentTag: UInt8                 //  8 uimsbf
    public let payload: [UInt8]                    //  1 byte * n
    init(_ wrapper: ByteArray) throws {
        self.descriptorTag = try wrapper.get()
        self.descriptorLength = try wrapper.get()
        self.componentTag = try wrapper.get()
        // componentTag分
        if descriptorLength == 0x01 {
            self.payload = []
        } else {
            self.payload = try wrapper.take(Int(descriptorLength)-1) // descriptorLength -1byte(componentTag分)
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
extension StreamDescriptor {
    public var length: Int {
        return 2+Int(descriptorLength)
    }
}
