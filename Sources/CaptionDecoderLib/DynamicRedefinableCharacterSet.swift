// 
//  DynamicRedefinableCharacterSet.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/09.
//

// DRCS
// http://txqz.net/memo/2012-1118-1434.html
// ARIB-STD-B24 第一編第2部付録規定D
import Foundation

public struct DRCS {
    let numberOfCode: UInt8             //  8 uimsbf
    let codes: [Code]
    init(_ bytes: [UInt8]) {
        self.numberOfCode = bytes[0]
        var bytes = Array(bytes.suffix(bytes.count - 1)) // 1byte(codes前まで)
        var array: [Code] = []
        for _ in 0..<numberOfCode {
            let code = Code(bytes)
            array.append(code)
            let sub = code.length // 3byte + 可変長
            bytes = Array(bytes.suffix(bytes.count - sub))
        }
        self.codes = array
    }
}
extension DRCS : CustomStringConvertible {
    public var description: String {
        return "DRCS(numberOfCode: \(String(format: "0x%02x", numberOfCode))"
            + ", codes: \(codes))"
    }
}

struct Code {
    let characterCode: UInt16           // 16 uimsbf
    let numberOfFont: UInt8             //  8 uimsbf
    let fonts: [Font]
    init(_ bytes: [UInt8]) {
        self.characterCode = UInt16(bytes[0])<<8 | UInt16(bytes[1])
        self.numberOfFont = bytes[2]
        var bytes = Array(bytes.suffix(bytes.count - 3)) // 3byte(fonts前まで)
        var array: [Font] = []
        for _ in 0..<numberOfFont {
            let font = Font(bytes)
            array.append(font)
            let sub = font.length // 4 or 5 byte + 可変長
            bytes = Array(bytes.suffix(bytes.count - sub))
        }
        self.fonts = array
    }
}
extension Code {
    var length: Int {
        var sum = 0
        for font in self.fonts {
            sum += font.length
        }
        return Int(3 + sum)
    }
}

extension Code : CustomStringConvertible {
    public var description: String {
        return "Code(characterCode: \(String(format: "0x%04x", characterCode))"
            + ", numberOfFont: \(String(format: "0x%02x", numberOfFont))"
            + ", fonts: \(fonts))"
    }
}
struct Font {
    let fontId: UInt8                   //  4 uimsbf
    let mode: UInt8                     //  4 bslbf
    let depth: UInt8?                   //  8 uimsbf
    let width: UInt8?                   //  8 uimsbf
    let height: UInt8?                  //  8 uimsbf
    let regionX: UInt8?                 //  8 uimsbf
    let regionY: UInt8?                 //  8 uimsbf
    let geometricDataLength: UInt16?    // 16 uimsbf
    let payload: [UInt8]
    init(_ bytes: [UInt8]) {
        self.fontId = bytes[0]&0xF0>>4
        self.mode = bytes[0]&0x0F
        let isCompression = bytes[0]&0x0F != 0x0 && bytes[0]&0x0F != 0x1
        if isCompression {
            self.depth = nil
            self.width = nil
            self.height = nil
            self.regionX = bytes[1]
            self.regionY = bytes[2]
            self.geometricDataLength = UInt16(bytes[3])<<8 | UInt16(bytes[4])
        } else {
            self.depth = bytes[1]
            self.width = bytes[2]
            self.height = bytes[3]
            self.regionX = nil
            self.regionY = nil
            self.geometricDataLength = nil
        }
        self.payload = isCompression ? Array(bytes[5..<5+numericCast(Int(regionX!) * Int(regionY!) * Int(geometricDataLength!))/8]) : Array(bytes[4..<4+numericCast(Int(depth!) * Int(width!) * Int(height!))/8])
    }
}
extension Font {
    var length: Int {
        // 1 byte(fontId+mode)
        if isCompression {
            return Int(1 + 1 + 1 + 2 + self.payload.count)
        } else {
            return Int(1 + 1 + 1 + 1 + self.payload.count)
        }
    }
    var isCompression: Bool {
        return mode != 0x0 && mode != 0x1
    }
}
extension Font : CustomStringConvertible {
    public var description: String {
        return "Font(fontId: \(String(format: "0x%02x", fontId))"
            + ", mode: \(String(format: "0x%02x", mode))"/*
            + ", depth: \(String(format: "0x%02x", depth))"
            + ", width: \(String(format: "0x%02x", width))"
            + ", height: \(String(format: "0x%02x", height))"
            + ", regionX: \(String(format: "0x%02x", regionX))"
            + ", regionY: \(String(format: "0x%02x", regionY))"
            + ", geometricDataLength: \(String(format: "0x%04x", geometricDataLength))"
            + ")"*/
    }
}
