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
            return "ニュース/報道"
        case 0x01:
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
            return "スポーツ"
        case 0x02:
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
            return "情報/ワイドショー"
        case 0x03:
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
            return "ドラマ"
        case 0x04:
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
            return "音楽"
        case 0x05:
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
            return "バラエティ"
        case 0x06:
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
            return "映画"
        case 0x07:
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
            return "アニメ/特撮"
        case 0x08:
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
            return "ドキュメンタリー/教養"
        case 0x09:
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
            return "劇場/公演"
        case 0x0A:
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
            return "趣味/教育"
        case 0x0B:
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
                return ""
            default:
                break
            }
            return "その他"
        default:
            return ""
        }
    }
}
