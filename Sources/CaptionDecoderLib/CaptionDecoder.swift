// 
//  CaptionDecoder.swift
//  CaptionDecoder
//
//  Created by saga-dash on 2018/07/10.
//


import Foundation


public let LENGTH = 188
let PES_PRIVATE_DATA = 0x06             // ARIB STD-B24 表 4-1 伝送方式の種類
var targetPMTPID: UInt16 = 0xFFFF
var targetCaptionPID: UInt16 = 0xFFFF
var stock: Dictionary<UInt16, Data> = [:]

public func CaptionDecoderMain(data: Data) -> [Unit] {
    if data.count != LENGTH {
        return []
    }
    let header = TransportPacket(data)
    // TODO Enumにする
    // PAT?
    if header.PID == 0x00 {
        //printHexDumpForBytes(data)
        //print(header)
        let pat = ProgramAssociationTable(data)
        //printHexDumpForBytes(bytes: pat.programAssociationSection.hexDump)
        //print(pat.programAssociationSection)
        //print(pat)
        guard let program = pat.programs.first(where: {$0.programNumber>0}) else {
            // 番組番号に正常なものが無い
            fatalError("Not Found Program in PAT")
        }
        targetPMTPID = program.PID
        return []
    }
    // PMT?
    if header.PID == targetPMTPID {
        // はじめのunitではない&&前のデータがない
        if (header.payloadUnitStartIndicator != 0x01 && stock[header.PID] == nil) {
            return []
        }
        let newData: Data
        // 前のデータと結合
        if (stock[header.PID] != nil) {
            // ストックが存在し先頭TSならデータがおかしいので置き換える
            if header.payloadUnitStartIndicator == 0x01 {
                //stock.removeValue(forKey: header.PID)
                stock[header.PID] = data
                return []
            }
            newData = stock[header.PID]! + data.suffix(from: 4) // header 4byte
        } else {
            newData = data
        }
        guard let pmt = ProgramMapTable(newData) else {
            // データが足りていなければ、ストックする
            stock[header.PID] = newData
            return []
        }
        defer {
            stock.removeValue(forKey: header.PID)
        }
        //printHexDumpForBytes(newData)
        //print(pmt)
        // ToDo: PES_PRIVATE_DATAの定義探す
        let streams = pmt.stream.filter({$0.streamType==PES_PRIVATE_DATA})
        if streams.count == 0 {
            print("字幕無いよ")
            return []
        }
        //print("streams: \(streams)")
        // 字幕: 0x30, 0x87
        // 文字スーパー: 0x38, 0x88
        // ToDo: 定義探す
        guard let stream = streams.first(where:{nil != $0.descriptor.first(where:{$0.componentTag == 0x30})}) else {
            print("字幕無いよ2")
            return []
        }
        targetCaptionPID = stream.elementaryPID
        //print("targetCaptionPID: \(String(format: "0x%04x", targetCaptionPID))")
        return []
    }
    if header.PID == targetCaptionPID {
        // はじめのunitではない&&前のデータがない
        if header.payloadUnitStartIndicator != 0x01 && stock[header.PID] == nil {
            return []
        }
        let newData: Data
        // 前のデータと結合
        if (stock[header.PID] != nil) {
            newData = stock[header.PID]! + header.payload
        } else {
            newData = data
        }
        guard let caption = Caption(newData) else {
            stock[header.PID] = newData
            return []
        }
        defer {
            stock.removeValue(forKey: header.PID)
        }
        // ARIB STD-B24 第一編 第 3 部 表 9-2 字幕データとデータグループ識別の対応
        // 字幕管理: 0x00 or 0x20
        if caption.dataGroupId == 0x00 || caption.dataGroupId == 0x20 {
            return []
        }
        //printHexDumpForBytes(bytes: caption.payload)
        //print(caption)
        let result = caption.dataUnit.map({(dataUnit: DataUnit) -> Unit? in
            // ARIB STD-B24 第一編 第 3 部 表 9-12 データユニットの種類
            // 本文: 0x20, 1バイト DRCS: 0x30, 2バイト DRCS: 0x31
            switch dataUnit.dataUnitParameter {
            case 0x20:
                //printHexDumpForBytes(bytes: dataUnit.payload)
                let result = ARIB8charDecode(dataUnit)
                return result
            case 0x30, 0x31:
                print("DRCSじゃん!")
                return nil
            default:
                print("dataUnit.dataUnitParameter: \(dataUnit.dataUnitParameter)")
                return nil
            }
        }).filter({$0 != nil}) as! [Unit]
        return result
    }
    return []
}
