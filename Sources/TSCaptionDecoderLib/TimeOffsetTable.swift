// 
//  TimeOffsetTable.swift
//  TSCaptionDecoderLib
//
//  Created by saga-dash on 2018/07/25.
//


import Foundation
import ByteArrayWrapper

// ARIB STD-B10 第2部 5.2.9 時刻日付オフセットテーブル(TOT)(TimeOffsetTable)
// ARIB STD-B10 第1部 図 6.1-9 TOT のデータ構造
public struct TimeOffsetTable {
    public let header: TransportPacket
    public let tableId: UInt8                       //  8  uimsbf
    public let sectionSyntaxIndicator: UInt8        //  1  bslbf
    //'0'                                           //  1  bslbf
    //public let _reserved1: UInt8                  //  2  bslbf
    public let sectionLength: UInt16                // 12  uimsbf
    public let jstTime: UInt64                      // 40  bslbf
    // ToDo:
    public init?(_ data: Data, _ _header: TransportPacket? = nil) throws {
        self.header = try getHeader(data, _header)
        let bytes = header.payload()
        let wrapper = ByteArray(bytes)
        self.tableId = try wrapper.get()
        if tableId != 0x73 {
            return nil
        }
        self.sectionSyntaxIndicator = (try wrapper.get(doMove: false)&0x80)>>7
        self.sectionLength = UInt16(try wrapper.get(num: 2)&0x0FFF)
        self.jstTime = UInt64(try wrapper.get(num: 5))
        // ToDo: CRC_32
    }
}
extension TimeOffsetTable : CustomStringConvertible {
    public var description: String {
        return "TimeOffsetTable(tableId: \(String(format: "0x%02x", tableId))"
            + ", sectionSyntaxIndicator: \(sectionSyntaxIndicator)"
            + ", sectionLength: \(String(format: "0x%04x", sectionLength))"
            + ", jstTime: \(String(format: "0x%x", jstTime))(\(convertJSTStr(convertMJD(jstTime)) ?? ""))"
            + ")"
    }
}
extension TimeOffsetTable {
    public var date: Date? {
        return convertMJD(jstTime)
    }
}
