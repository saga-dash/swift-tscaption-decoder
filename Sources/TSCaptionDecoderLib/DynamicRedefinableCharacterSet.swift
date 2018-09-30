// 
//  DynamicRedefinableCharacterSet.swift
//  TSCaptionDecoderLib
//
//  Created by saga-dash on 2018/07/09.
//

// DRCS
// http://txqz.net/memo/2012-1118-1434.html
// ARIB-STD-B24 第一編第2部付録規定D
import Foundation
import ByteArrayWrapper

public struct DRCS {
    let numberOfCode: UInt8             //  8 uimsbf
    let codes: [Code]
    init(_ bytes: [UInt8]) throws {
        let wrapper = ByteArray(bytes)
        self.numberOfCode = try wrapper.get()
        var array: [Code] = []
        for _ in 0..<numberOfCode {
            let code = try Code(wrapper)
            array.append(code)
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
    init(_ wrapper: ByteArray) throws {
        self.characterCode = UInt16(try wrapper.get(num: 2))
        self.numberOfFont = try wrapper.get()
        var array: [Font] = []
        for _ in 0..<numberOfFont {
            let font = try Font(wrapper)
            array.append(font)
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
    init(_ wrapper: ByteArray) throws {
        let fontId = (try wrapper.get(doMove: false)&0xF0)>>4
        self.fontId = fontId
        self.mode = try wrapper.get()&0x0F
        let isCompression = fontId&0x0F != 0x0 && fontId&0x0F != 0x1
        if isCompression {
            self.depth = nil
            self.width = nil
            self.height = nil
            self.regionX = try wrapper.get()
            self.regionY = try wrapper.get()
            self.geometricDataLength = UInt16(try wrapper.get(num: 2))
            // ToDo: 定義探す
            let fontLength = Int(regionX!) * Int(regionY!) * Int(geometricDataLength!)/8
            try wrapper.setIndex(wrapper.getIndex() - 5)
            self.payload = try wrapper.take(fontLength)
        } else {
            self.depth = try wrapper.get()
            self.width = try wrapper.get()
            self.height = try wrapper.get()
            self.regionX = nil
            self.regionY = nil
            self.geometricDataLength = nil
            // depth+2: 色の深度、 (depth+2)/2: 使用するbit数
            let fontLength = Int(depth!+2)/2 * Int(width!) * Int(height!)/8
            try wrapper.setIndex(wrapper.getIndex() - 4)
            self.payload = try wrapper.take(fontLength)
        }
    }
}
extension Font {
    var length: Int {
        return self.payload.count
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
