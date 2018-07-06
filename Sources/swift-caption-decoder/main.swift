//
//  main.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation

let file = FileHandle.standardInput
let LENGTH = 188
let PES_PRIVATE_DATA = 0x06
var targetPMTPID: UInt16 = 0xFFFF
var targetCaptionPID: UInt16 = 0xFFFF
var stock: Dictionary<UInt16, Data> = [:]

while true {
    let data = file.readData(ofLength: LENGTH)
    if data.count != LENGTH {
        break
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
        continue
    }
    // PMT?
    if header.PID == targetPMTPID {
        // はじめのunitではない&&前のデータがない
        if (header.payloadUnitStartIndicator != 0x01 && stock[header.PID] == nil) {
            continue
        }
        let newData: Data
        // 前のデータと結合
        if (stock[header.PID] != nil) {
            newData = stock[header.PID]! + data.suffix(from: 4) // header 4byte
        } else {
            newData = data
        }
        guard let pmt = ProgramMapTable(newData) else {
            // データが足りていなければ、ストックする
            stock[header.PID] = newData
            continue
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
            continue
        }
        //print("streams: \(streams)")
        // 字幕: 0x30, 0x87
        // 文字スーパー: 0x38, 0x88
        // ToDo: 定義探す
        guard let stream = streams.first(where: {$0.descriptor.componentTag==0x30}) else {
            print("字幕無いよ2")
            continue
        }
        targetCaptionPID = stream.elementaryPID
        //print("targetCaptionPID: \(String(format: "0x%04x", targetCaptionPID))")
        continue
    }
    if header.PID == targetCaptionPID {
        // はじめのunitではない&&前のデータがない
        if header.payloadUnitStartIndicator != 0x01 && stock[header.PID] == nil {
            continue
        }
        let newData: Data
        // 前のデータと結合
        if (stock[header.PID] != nil) {
            newData = stock[header.PID]! + data.suffix(from: 4) // header 4byte
        } else {
            newData = data
        }
        guard let caption = Caption(newData) else {
            stock[header.PID] = newData
            continue
        }
        defer {
            stock.removeValue(forKey: header.PID)
        }
        printHexDumpForBytes(bytes: caption.payload)
        print(caption)
        continue
    }
}
print("fin")

