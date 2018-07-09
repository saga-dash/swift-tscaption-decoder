//
//  main.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation
import CaptionDecoderLib

let file = FileHandle.standardInput

while true {
    let data = file.readData(ofLength: LENGTH)
    if data.count != LENGTH {
        break
    }
    guard let caption = CaptionDecoderMain(data: data) else {
        continue
    }
    for dataUnit in caption.dataUnit {
        // ARIB STD-B24 第一編 第 3 部 表 9-12 データユニットの種類
        // 本文: 0x20, 1バイト DRCS: 0x30, 2バイト DRCS: 0x31
        switch dataUnit.dataUnitParameter {
        case 0x20:
            //printHexDumpForBytes(bytes: dataUnit.payload)
            let result = ARIB8charDecode(dataUnit)
            print(result.str)
        case 0x30, 0x31:
            print("DRCSじゃん!")
        default:
            print("dataUnit.dataUnitParameter: \(dataUnit.dataUnitParameter)")
        }
    }
}
