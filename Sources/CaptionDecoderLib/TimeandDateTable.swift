// 
//  TimeandDateTable.swift
//  CaptionDecoderLib
//
//  Created by saga-dash on 2018/07/25.
//


import Foundation

// ARIB STD-B10 第2部 5.2.8 時刻日付テーブル(TDT)(TimeandDateTable)
// ARIB STD-B10 第1部 図 6.1-8 TDT のデータ構造
public struct TimeandDateTable {
    public let header: TransportPacket
    public let tableId: UInt8                       //  8  uimsbf
    public let sectionSyntaxIndicator: UInt8        //  1  bslbf
    //'0'                                           //  1  bslbf
    //public let _reserved1: UInt8                  //  2  bslbf
    public let sectionLength: UInt16                // 12  uimsbf
    public let jstTime: UInt64                      // 40  bslbf
    public init?(_ data: Data, _ _header: TransportPacket? = nil) {
        self.header = _header ?? TransportPacket(data)
        let bytes = header.payload
        self.tableId = bytes[0]
        if tableId != 0x70 {
            return nil
        }
        self.sectionSyntaxIndicator = (bytes[1]&0x80)>>7
        self.sectionLength = UInt16(bytes[1]&0x0F)<<8 | UInt16(bytes[2])
        self.jstTime = UInt64(bytes[3])<<32 | UInt64(bytes[4])<<24 | UInt64(bytes[5])<<16 | UInt64(bytes[6])<<8 | UInt64(bytes[7])
    }
}
extension TimeandDateTable : CustomStringConvertible {
    public var description: String {
        return "TimeandDateTable(tableId: \(String(format: "0x%02x", tableId))"
            + ", sectionSyntaxIndicator: \(sectionSyntaxIndicator)"
            + ", sectionLength: \(String(format: "0x%04x", sectionLength))"
            + ", jstTime: \(String(format: "0x%x", jstTime))(\(convertJSTStr(self.date) ?? ""))"
            + ")"
    }
}
extension TimeandDateTable {
    public var date: Date? {
        return convertMJD(jstTime)
    }
}
