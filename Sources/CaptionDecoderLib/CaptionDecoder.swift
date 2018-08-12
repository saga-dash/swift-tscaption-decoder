// 
//  CaptionDecoder.swift
//  CaptionDecoder
//
//  Created by saga-dash on 2018/07/10.
//


import Foundation


public let LENGTH = 188
let PES_PRIVATE_DATA = 0x06             // ARIB STD-B24 第三編 表 4-1 伝送方式の種類
var targetPMTPID: UInt16 = 0xFFFF
var targetCaptionPID: UInt16 = 0xFFFF
var stock: Dictionary<UInt16, Data> = [:]
var presentEventId: UInt16? = nil
var presentServiceId: String? = nil
var tsDate: Date = Date()
var blackList: [String] = [
    "お住まいの地域の詳しい気象情報、全国の天気ほか",
    "デジタル放送のコピー制御（著作権保護）システムとＢ－ＣＡＳカードなどについての説明と問い合わせなど",
    "いつでも見ることができるＮＨＫの最新のニュース",
]

public func CaptionDecoderMain(data: Data, options: Options) throws -> [Unit] {
    if data.count != LENGTH {
        return []
    }
    var header = try TransportPacket(data)
    var data = data
    // はじめのunitではない&&前のデータがない
    if (header.payloadUnitStartIndicator != 0x01 && stock[header.PID] == nil) {
        return []
    }
    // 前のデータと結合
    if (stock[header.PID] != nil) {
        // ストックが存在し先頭TSならデータがおかしいので置き換える
        if header.payloadUnitStartIndicator == 0x01 {
            stock[header.PID] = data
        } else {
            // PIDに対してCounterが正常に加算されているか
            if isCorrectCounter(stock[header.PID]!, data) {
                data = stock[header.PID]! + header.payload
            } else {
                stock.removeValue(forKey: header.PID)
                return []
            }
        }
    }
    header = try TransportPacket(data)
    if !header.enoughHeaderLength {
        // データが足りていなければ、ストックする
        stock[header.PID] = data
        return []
    }
    // TODO Enumにする
    // PAT?
    if header.PID == 0x00 {
        //printHexDumpForBytes(data)
        //print(header)
        guard let pat = try ProgramAssociationTable(data, header) else {
            // データが足りていなければ、ストックする
            stock[header.PID] = data
            return []
        }
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
    // TDT or TOT?
    if header.PID == 0x14 {
        guard let date = try TimeOffsetTable(data)?.date else {
            guard let date = try TimeandDateTable(data)?.date else {
                print("不正な時刻")
                return []
            }
            //print("TDT", convertJSTStr(date) ?? "error convert time")
            tsDate = date
            return []
        }
        //print("TOT", convertJSTStr(date) ?? "error convert time")
        tsDate = date
        return []
    }
    // PMT?
    else if header.PID == targetPMTPID {
        guard let pmt = try ProgramMapTable(data) else {
            // データが足りていなければ、ストックする
            stock[header.PID] = data
            return []
        }
        defer {
            stock.removeValue(forKey: header.PID)
        }
        //printHexDumpForBytes(data)
        //print(pmt)
        let streams = pmt.stream.filter({$0.streamType==PES_PRIVATE_DATA})
        if streams.count == 0 {
            print("字幕無いよ")
            return []
        }
        //print("streams: \(streams)")
        // 字幕: 0x30, 0x87
        // 文字スーパー: 0x38, 0x88
        // ARIB TR-B14 第四編 第1部14 表 14-1 component_tag の割当て
        guard let stream = streams.first(where:{nil != $0.descriptor.first(where:{$0.componentTag == options.streamComponentTag.rawValue})}) else {
            print("字幕無いよ2")
            return []
        }
        targetCaptionPID = stream.elementaryPID
        //print("targetCaptionPID: \(String(format: "0x%04x", targetCaptionPID))")
        return []
    }
    else if header.PID == targetCaptionPID {
        //printHexDumpForBytes(data)
        guard let caption = try Caption(data) else {
            stock[header.PID] = data
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
        let result = try caption.dataUnit.map({(dataUnit: DataUnit) -> Unit? in
            // ARIB STD-B24 第一編 第 3 部 表 9-12 データユニットの種類
            // 本文: 0x20, 1バイト DRCS: 0x30, 2バイト DRCS: 0x31
            switch dataUnit.dataUnitParameter {
            case 0x20:
                //printHexDumpForBytes(bytes: dataUnit.payload)
                var result = ARIB8charDecode(dataUnit)
                result.eventId = presentEventId
                result.serviceId = presentServiceId
                return result
            case 0x30, 0x31:
                //print(data.map({String(format: "0x%02x", $0)}).joined(separator: ", "))
                let drcs = try DRCS(dataUnit.payload)
                //print(drcs)
                var controls: [Control] = []
                for code in drcs.codes {
                    for font in code.fonts {
                        let control = Control.init(.DRCS, payload: font.payload)
                        controls.append(control)
                    }
                }
                var result = Unit(str: "", control: controls)
                result.eventId = presentEventId
                result.serviceId = presentServiceId
                return result
            default:
                print("dataUnit.dataUnitParameter: \(dataUnit.dataUnitParameter)")
                return nil
            }
        }).filter({$0 != nil}) as! [Unit]
        return result
    }
    // EIT
    else if header.PID == 0x0012 {// || header.PID == 0x0026 || header.PID == 0x0027 {
        // 固定用: 0x0012, ワンセグ受信用: 0x0027
        if header.payload[0] != 0x004E {
            // tableId: payload[0] == 0x004E == P/F
            return []
        }
        if header.payloadUnitStartIndicator != 0x01 {
            return []
        }
        guard let eit = try EventInformationTable(data) else {
            // データが足りていなければ、ストックする
            stock[header.PID] = data
            return []
        }
        defer {
            stock.removeValue(forKey: header.PID)
        }
        // present(実行中)
        if !eit.isPresent {
            return []
        }
        let event = eit.events.first!
        // 番組表(0x4E)記述子を取得
        guard let shortDescriptor = event.shortDescriptor else {
            return []
        }
        // S1のガイド用番組を除外
        if blackList.contains(shortDescriptor.textStr) {
            return []
        }
        // ToDo: スクランブル時の処理
        //print(eit.header)
        //printHexDumpForBytes(data)
        //print(eit)
        //print(event)
        presentEventId = event.eventId
        presentServiceId = eit.serviceName
    }
    return []
}
func isCorrectCounter(_ src: Data, _ target: Data) -> Bool {
    let srcCounter = Int([UInt8](src)[3]&0x0F)
    let targetCounter = Int([UInt8](target)[3]&0x0F)
    return (srcCounter + src.count/(LENGTH-4)) % 16 == targetCounter
}

public struct Options {
    let streamComponentTag: StreamComponentTag
    public init(_ streamComponentTag: StreamComponentTag) {
        self.streamComponentTag = streamComponentTag
    }
}
public enum StreamComponentTag: UInt8 {
    case subtitle   = 0x30
    case subtitle1  = 0x31
    case subtitle2  = 0x32
    case subtitle3  = 0x33
    case subtitle4  = 0x34
    case subtitle5  = 0x35
    case subtitle6  = 0x36
    case subtitle7  = 0x37
    case teletext   = 0x38
    case teletext1  = 0x39
    case teletext2  = 0x3A
    case teletext3  = 0x3B
    case teletext4  = 0x3C
    case teletext5  = 0x3D
    case teletext6  = 0x3E
    case teletext7  = 0x3F
}
