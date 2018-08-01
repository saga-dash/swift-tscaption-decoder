// 
//  EventInformationTable.swift
//  CaptionDecoderLib
//
//  Created by saga-dash on 2018/07/18.
//


import Foundation


// ARIB STD-B10 第2部 表5-7
public struct EventInformationTable {
    public let header: TransportPacket
    public let programAssociationSection: ProgramAssociationSection
    public let transportStreamId: UInt16        // 16  uimsbf
    public let originalNetworkId: UInt16        // 16  uimsbf
    public let segmentLastSectionNumber: UInt8  //  8  uimsbf
    public let lastTableId: UInt8               //  8  uimsbf
    public let payload: [UInt8]                 //  n  byte
    public let events: [Event]
    public init?(_ data: Data) {
        self.header = TransportPacket(data)
        self.programAssociationSection = ProgramAssociationSection(data, header)
        let tableId = programAssociationSection.tableId
        if tableId < 0x4E || 0x6F < tableId {
            return nil
        }
        var bytes = programAssociationSection.payload
        // 5 byte(programAssociationSection終わりまで)
        if bytes.count < Int(programAssociationSection.sectionLength)-5 {
            return nil
        }
        self.transportStreamId = UInt16(bytes[0])<<8 | UInt16(bytes[1])
        self.originalNetworkId = UInt16(bytes[2])<<8 | UInt16(bytes[3])
        self.segmentLastSectionNumber = bytes[4]
        self.lastTableId = bytes[5]
        self.payload = Array(bytes.suffix(bytes.count - Int(6))) // 6byte(固定長)
        if Int(programAssociationSection.sectionLength) - 11 - 4 < 0 {
            return nil
        }
        var payloadLength = programAssociationSection.sectionLength
            - 11 // EIT(sessionLength以下の固定分) 5 + 6 byte
            - 4 // CRC_32
        bytes = Array(bytes.suffix(bytes.count - 6))
        var array: [Event] = []
        repeat {
            let event = Event(bytes)
            let sub = event.length // 可変長(Event)
            if sub > bytes.count {
                break
            }
            array.append(event)
            bytes = Array(bytes.suffix(bytes.count - sub))
            payloadLength -= numericCast(sub)
        } while payloadLength > 12
        self.events = array
    }
}
extension EventInformationTable : CustomStringConvertible {
    public var description: String {
        return "EventInformationTable(PID: \(String(format: "0x%04x", header.PID))"
            + ", tableId: \(String(format: "0x%02x", tableId))"
            + ", serviceId: \(String(format: "0x%04x", serviceId))"
            + ", serviceName: \(serviceName)"
            + ", sectionLength: \(String(format: "0x%04x", sectionLength))"
            + ", transportStreamId: \(String(format: "0x%04x", transportStreamId))"
            + ", originalNetworkId: \(String(format: "0x%04x", originalNetworkId))"
            + ", segmentLastSectionNumber: \(String(format: "0x%04x", segmentLastSectionNumber))"
            + ", lastTableId: \(String(format: "0x%04x", lastTableId))"
            + ", events: \(events)"
            + ")"
    }
    public var isPresent: Bool {
        return tableId == 0x4E && programAssociationSection.sectionNumber == 0x00
    }
    public var isFollowing: Bool {
        return tableId == 0x4E && programAssociationSection.sectionNumber == 0x01
    }
}
extension EventInformationTable {
    public var tableId: UInt8 {
        return programAssociationSection.tableId
    }
    public var serviceId: UInt16 {
        return programAssociationSection.serviceId
    }
    public var sectionLength: UInt16 {
        return programAssociationSection.sectionLength
    }
    public var serviceName: String {
        switch serviceId {
        case 1024, 1025:
            return "g1"
        case 1032, 1033, 1034:
            return "e1"
        case 101, 102:
            return "s1"
        case 103, 104:
            return "s3"
        default:
            return ""
        }
    }
}

public struct Event {
    public let eventId: UInt16                  // 16  uimsbf
    public let startTime: UInt64                // 40  bslbf
    public let duration: UInt32                 // 24  uimsbf
    public let runningStatus: UInt8             //  3  uimsbf 表 5-6 SDT 進行状態
    public let freeCAMode: UInt8                //  1  bslbf
    public let descriptorsLoopLength: UInt16    // 12  uimsbf
    public let descriptors: [EventDescriptor]
    // ToDo: CRC
    public init(_ bytes: [UInt8]) {
        self.eventId = UInt16(bytes[0])<<8 | UInt16(bytes[1])
        self.startTime = UInt64(bytes[2])<<32 | UInt64(bytes[3])<<24 | UInt64(bytes[4])<<16 | UInt64(bytes[5])<<8 | UInt64(bytes[6])
        self.duration = UInt32(bytes[7])<<16 | UInt32(bytes[8])<<8 | UInt32(bytes[9])
        self.runningStatus = (bytes[10]&0xE0)>>5
        self.freeCAMode = (bytes[10]&0x10)>>4
        self.descriptorsLoopLength = UInt16(bytes[10]&0x0F)<<8 | UInt16(bytes[11])
        var bytes = Array(bytes.suffix(bytes.count - numericCast(12))) // 12 byte(Eventサイズ)
        bytes = Array(bytes.prefix(numericCast(descriptorsLoopLength)))
        var payloadLength = bytes.count
        var array: [EventDescriptor] = []
        repeat {
            guard let descriptor = convertEventDescriptor(bytes) else {
                break
            }
            array.append(descriptor)
            let sub = descriptor.length // 可変長(EventDescriptor)
            bytes = Array(bytes.suffix(bytes.count - sub))
            payloadLength -= numericCast(sub)
        } while payloadLength > 4 // 4 byte(CRC)
        self.descriptors = array
    }
}
extension Event : CustomStringConvertible {
    public var description: String {
        return "Event(eventId: \(String(format: "0x%04x", eventId))"
            + ", startTime: \(String(format: "0x%x", startTime))(\(eventDateStr ?? ""))"
            + ", duration: \(String(format: "0x%06x", duration))(\(eventSec)s)"
            + ", runningStatus: \(String(format: "0x%02x", runningStatus))"
            + ", freeCAMode: \(String(format: "0x%04x", freeCAMode))"
            + ", descriptorsLoopLength: \(String(format: "0x%04x", descriptorsLoopLength))"
            + ", descriptors: \(descriptors)"
            + ")"
    }
}
extension Event {
    var length: Int {
        // 12 byte(固定分) + 可変長
        return Int(12 + descriptorsLoopLength)
    }
    func isOnAir(_ target: Date = Date()) -> Bool {
        guard let date = eventDate else {
            return false
        }
        let interval = Int(target.timeIntervalSince(date))
        return 0 < interval && interval < eventSec
    }
    var eventDate: Date? {
        let date = convertMJD(startTime)
        return date
    }
    var eventDateStr: String? {
        let str = convertJSTStr(eventDate)
        return str
    }
    var eventSec: Int {
        let date = convertARIBTime(duration)
        if date.second == nil || date.minute == nil || date.hour == nil {
            return 0
        }
        return date.second! + date.minute! * 60 + date.hour! * 60 * 60
    }
    var shortDescriptor: ShortEventDescriptor? {
        guard let descriptor = descriptors.first(where: {$0.descriptorTag == 0x4D}) else {
            return nil
        }
        return descriptor as? ShortEventDescriptor
    }
}
