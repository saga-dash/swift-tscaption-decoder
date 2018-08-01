// 
//  ContentDescriptor.swift
//  CaptionDecoderLib
//
//  Created by saga-dash on 2018/08/01.
//


import Foundation


// ARIB STD-B10 第1部  図 6.2-19 コンテント記述子のデータ構造
public struct ContentDescriptor: EventDescriptor {
    public let descriptorTag: UInt8                 //  8 uimsbf
    public let descriptorLength: UInt8              //  8 uimsbf
    public let contents: [ContentDescriptorSub]
    public init(_ bytes: [UInt8]) {
        self.descriptorTag = bytes[0]
        self.descriptorLength = bytes[1]
        var bytes = Array(bytes.suffix(bytes.count - numericCast(2))) // 2 byte(ContentDescriptorサイズ)
        var payloadLength = descriptorLength
        var array: [ContentDescriptorSub] = []
        repeat {
            let contentSub = ContentDescriptorSub(bytes)
            array.append(contentSub)
            let sub = 2 // 2 byte 固定長(ContentDescriptorSub)
            bytes = Array(bytes.suffix(bytes.count - sub))
            payloadLength -= numericCast(sub)
        } while payloadLength > 2
        self.contents = array
    }
}
extension ContentDescriptor : CustomStringConvertible {
    public var description: String {
        return "ContentDescriptor(descriptorTag: \(String(format: "0x%02x", descriptorTag))"
            + ", descriptorLength: \(String(format: "0x%02x", descriptorLength))"
            + ", contents: \(contents)"
            + ")"
    }
}

public struct ContentDescriptorSub {
    public let contentNibbleLevel1: UInt8           //  4 uimsbf
    public let contentNibbleLevel2: UInt8           //  4 uimsbf
    public let userNibble1: UInt8                   //  4 uimsbf
    public let userNibble2: UInt8                   //  4 uimsbf
    init(_ bytes: [UInt8]) {
        self.contentNibbleLevel1 = (bytes[0]&0xF0)>>4
        self.contentNibbleLevel2 = (bytes[0]&0x0F)
        self.userNibble1 = (bytes[1]&0xF0)>>4
        self.userNibble2 = (bytes[1]&0x0F)
    }
}
extension ContentDescriptorSub : CustomStringConvertible {
    public var description: String {
        return "ContentDescriptorSub(LargeGenreClassification: \(largeGenreClassification)"
            + ", middleGenreClassification: \(middleGenreClassification)"
            + ", userNibble: \(String(format: "0x%02x", userNibble1<<4 | userNibble2))"
            + ")"
    }
}
extension ContentDescriptorSub {
    // ARIB STD-B10 第2部  付録H [ジャンル大分類]
    public var largeGenreClassification: String {
        switch contentNibbleLevel1 {
        case 0x00:
            return "ニュース/報道"
        case 0x01:
            return "スポーツ"
        case 0x02:
            return "情報/ワイドショー"
        case 0x03:
            return "ドラマ"
        case 0x04:
            return "音楽"
        case 0x05:
            return "バラエティ"
        case 0x06:
            return "映画"
        case 0x07:
            return "アニメ/特撮"
        case 0x08:
            return "ドキュメンタリー/教養"
        case 0x09:
            return "劇場/公演"
        case 0x0A:
            return "趣味/教育"
        case 0x0B:
            return "福祉"
        case 0x0C, 0x0D:
            return "予備"
        case 0x0E:
            return "拡張"
        case 0x0F:
            return "その他"
        default:
            return ""
        }
    }
    // ARIB STD-B10 第2部  付録H [ジャンル中分類]
    public var middleGenreClassification: String {
        switch contentNibbleLevel1 {
        case 0x00:
            switch contentNibbleLevel2 {
            case 0x00:
                return "定時・総合"
            case 0x01:
                return "天気"
            case 0x02:
                return "特集・ドキュメント"
            case 0x03:
                return "政治・国会"
            case 0x04:
                return "経済・市況"
            case 0x05:
                return "海外・国際"
            case 0x06:
                return "解説"
            case 0x07:
                return "討論・会談"
            case 0x08:
                return "報道特番"
            case 0x09:
                return "ローカル・地域"
            case 0x0A:
                return "交通"
            case 0x0B:
                return ""
            case 0x0C:
                return ""
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return "その他"
            default:
                break
            }
            return "ニュース/報道"
        case 0x01:
            switch contentNibbleLevel2 {
            case 0x00:
                return "スポーツニュース"
            case 0x01:
                return "野球"
            case 0x02:
                return "サッカー"
            case 0x03:
                return "ゴルフ"
            case 0x04:
                return "その他の球技"
            case 0x05:
                return "相撲・格闘技"
            case 0x06:
                return "オリンピック・国際大会"
            case 0x07:
                return "マラソン・陸上・水泳"
            case 0x08:
                return "モータースポーツ"
            case 0x09:
                return "マリン・ウィンタースポーツ"
            case 0x0A:
                return "競馬・公営競技"
            case 0x0B:
                return ""
            case 0x0C:
                return ""
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return "その他"
            default:
                break
            }
            return "スポーツ"
        case 0x02:
            switch contentNibbleLevel2 {
            case 0x00:
                return "芸能・ワイドショー"
            case 0x01:
                return "ファッション"
            case 0x02:
                return "暮らし・住まい"
            case 0x03:
                return "健康・医療"
            case 0x04:
                return "ショッピング・通販"
            case 0x05:
                return "グルメ・料理"
            case 0x06:
                return "イベント"
            case 0x07:
                return "番組紹介・お知らせ"
            case 0x08:
                return ""
            case 0x09:
                return ""
            case 0x0A:
                return ""
            case 0x0B:
                return ""
            case 0x0C:
                return ""
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return "その他"
            default:
                break
            }
            return "情報/ワイドショー"
        case 0x03:
            switch contentNibbleLevel2 {
            case 0x00:
                return "国内ドラマ"
            case 0x01:
                return "海外ドラマ"
            case 0x02:
                return "時代劇"
            case 0x03:
                return ""
            case 0x04:
                return ""
            case 0x05:
                return ""
            case 0x06:
                return ""
            case 0x07:
                return ""
            case 0x08:
                return ""
            case 0x09:
                return ""
            case 0x0A:
                return ""
            case 0x0B:
                return ""
            case 0x0C:
                return ""
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return "その他"
            default:
                break
            }
            return "ドラマ"
        case 0x04:
            switch contentNibbleLevel2 {
            case 0x00:
                return "国内ロック・ポップス"
            case 0x01:
                return "海外ロック・ポップス"
            case 0x02:
                return "クラシック・オペラ"
            case 0x03:
                return "ジャズ・フュージョン"
            case 0x04:
                return "歌謡曲・演歌"
            case 0x05:
                return "ライブ・コンサート"
            case 0x06:
                return "ランキング・リクエスト"
            case 0x07:
                return "カラオケ・のど自慢"
            case 0x08:
                return "民謡・邦楽"
            case 0x09:
                return "童謡・キッズ"
            case 0x0A:
                return "民族音楽・ワールドミュージック"
            case 0x0B:
                return ""
            case 0x0C:
                return ""
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return "その他"
            default:
                break
            }
            return "音楽"
        case 0x05:
            switch contentNibbleLevel2 {
            case 0x00:
                return "クイズ"
            case 0x01:
                return "ゲーム"
            case 0x02:
                return "トークバラエティ"
            case 0x03:
                return "お笑い・コメディ"
            case 0x04:
                return "音楽バラエティ"
            case 0x05:
                return "旅バラエティ"
            case 0x06:
                return "料理バラエティ"
            case 0x07:
                return ""
            case 0x08:
                return ""
            case 0x09:
                return ""
            case 0x0A:
                return ""
            case 0x0B:
                return ""
            case 0x0C:
                return ""
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return "その他"
            default:
                break
            }
            return "バラエティ"
        case 0x06:
            switch contentNibbleLevel2 {
            case 0x00:
                return "洋画"
            case 0x01:
                return "邦画"
            case 0x02:
                return "アニメ"
            case 0x03:
                return ""
            case 0x04:
                return ""
            case 0x05:
                return ""
            case 0x06:
                return ""
            case 0x07:
                return ""
            case 0x08:
                return ""
            case 0x09:
                return ""
            case 0x0A:
                return ""
            case 0x0B:
                return ""
            case 0x0C:
                return ""
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return "その他"
            default:
                break
            }
            return "映画"
        case 0x07:
            switch contentNibbleLevel2 {
            case 0x00:
                return "国内アニメ"
            case 0x01:
                return "海外アニメ"
            case 0x02:
                return "特撮"
            case 0x03:
                return ""
            case 0x04:
                return ""
            case 0x05:
                return ""
            case 0x06:
                return ""
            case 0x07:
                return ""
            case 0x08:
                return ""
            case 0x09:
                return ""
            case 0x0A:
                return ""
            case 0x0B:
                return ""
            case 0x0C:
                return ""
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return "その他"
            default:
                break
            }
            return "アニメ/特撮"
        case 0x08:
            switch contentNibbleLevel2 {
            case 0x00:
                return "社会・時事"
            case 0x01:
                return "歴史・紀行"
            case 0x02:
                return "自然・動物・環境"
            case 0x03:
                return "宇宙・科学・医学"
            case 0x04:
                return "カルチャー・伝統文化"
            case 0x05:
                return "文学・文芸"
            case 0x06:
                return "スポーツ"
            case 0x07:
                return "ドキュメンタリー全般"
            case 0x08:
                return "インタビュー・討論"
            case 0x09:
                return ""
            case 0x0A:
                return ""
            case 0x0B:
                return ""
            case 0x0C:
                return ""
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return "その他"
            default:
                break
            }
            return "ドキュメンタリー/教養"
        case 0x09:
            switch contentNibbleLevel2 {
            case 0x00:
                return "現代劇・新劇"
            case 0x01:
                return "ミュージカル"
            case 0x02:
                return "ダンス・バレエ"
            case 0x03:
                return "落語・演芸"
            case 0x04:
                return "歌舞伎・古典"
            case 0x05:
                return ""
            case 0x06:
                return ""
            case 0x07:
                return ""
            case 0x08:
                return ""
            case 0x09:
                return ""
            case 0x0A:
                return ""
            case 0x0B:
                return ""
            case 0x0C:
                return ""
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return "その他"
            default:
                break
            }
            return "劇場/公演"
        case 0x0A:
            switch contentNibbleLevel2 {
            case 0x00:
                return "旅・釣り・アウトドア"
            case 0x01:
                return "園芸・ペット・手芸"
            case 0x02:
                return "音楽・美術・工芸"
            case 0x03:
                return "囲碁・将棋"
            case 0x04:
                return "麻雀・パチンコ"
            case 0x05:
                return "車・オートバイ"
            case 0x06:
                return "コンピュータ・TVゲーム"
            case 0x07:
                return "会話・語学"
            case 0x08:
                return "幼児・小学生"
            case 0x09:
                return "中学生・高校生"
            case 0x0A:
                return "大学生・受験"
            case 0x0B:
                return "生涯教育・資格"
            case 0x0C:
                return "教育問題"
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return "その他"
            default:
                break
            }
            return "趣味/教育"
        case 0x0B:
            switch contentNibbleLevel2 {
            case 0x00:
                return "高齢者"
            case 0x01:
                return "障害者"
            case 0x02:
                return "社会福祉"
            case 0x03:
                return "ボランティア"
            case 0x04:
                return "手話"
            case 0x05:
                return "文字(字幕)"
            case 0x06:
                return "音声解説"
            case 0x07:
                return ""
            case 0x08:
                return ""
            case 0x09:
                return ""
            case 0x0A:
                return ""
            case 0x0B:
                return ""
            case 0x0C:
                return ""
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return "その他"
            default:
                break
            }
            return "福祉"
        case 0x0C, 0x0D:
            switch contentNibbleLevel2 {
            case 0x00:
                return ""
            case 0x01:
                return ""
            case 0x02:
                return ""
            case 0x03:
                return ""
            case 0x04:
                return ""
            case 0x05:
                return ""
            case 0x06:
                return ""
            case 0x07:
                return ""
            case 0x08:
                return ""
            case 0x09:
                return ""
            case 0x0A:
                return ""
            case 0x0B:
                return ""
            case 0x0C:
                return ""
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return ""
            default:
                break
            }
            return "予備"
        case 0x0E:
            switch contentNibbleLevel2 {
            case 0x00:
                return "BS/地上デジタル放送用番組付属情報"
            case 0x01:
                return "広帯域 CS デジタル放送用拡張"
            case 0x02:
                return ""
            case 0x03:
                return "サーバー型番組付属情報"
            case 0x04:
                return "IP 放送用番組付属情報"
            case 0x05:
                return ""
            case 0x06:
                return ""
            case 0x07:
                return ""
            case 0x08:
                return ""
            case 0x09:
                return ""
            case 0x0A:
                return ""
            case 0x0B:
                return ""
            case 0x0C:
                return ""
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return "その他"
            default:
                break
            }
            return "拡張"
        case 0x0F:
            switch contentNibbleLevel2 {
            case 0x00:
                return ""
            case 0x01:
                return ""
            case 0x02:
                return ""
            case 0x03:
                return ""
            case 0x04:
                return ""
            case 0x05:
                return ""
            case 0x06:
                return ""
            case 0x07:
                return ""
            case 0x08:
                return ""
            case 0x09:
                return ""
            case 0x0A:
                return ""
            case 0x0B:
                return ""
            case 0x0C:
                return ""
            case 0x0D:
                return ""
            case 0x0E:
                return ""
            case 0x0F:
                return "その他"
            default:
                break
            }
            return "その他"
        default:
            return ""
        }
    }
}
