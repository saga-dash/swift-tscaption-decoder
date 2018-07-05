//
//  main.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation

let file = FileHandle.standardInput
let LENGTH = 188
var targetPMTPID: UInt16 = 0xFFFF
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
        printHexDumpForBytes(newData)
        print(header)
        print(pmt)
        stock.removeValue(forKey: header.PID)
    }
}
print("fin")

