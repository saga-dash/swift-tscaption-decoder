// 
//  CRC.swift
//  CaptionDecoderLib
//
//  Created by saga-dash on 2018/07/14.
//


import Foundation

//CRC-16-CCITT x^{{16}}+x^{{12}}+x^{5}+1
func crc16(_ data: [UInt8], _ crcPayload: UInt16) -> Bool {
    let crcCalc = CRC16.CCITT.calculate(Data(bytes: data))
    return crcCalc == crcPayload
}
final class CRC16 {
    static let CCITT: CRC16 = CRC16(polynomial: 0x1021)
    let table: [UInt16]
    init(polynomial: UInt16) {
        var table: [UInt16] = [UInt16](repeating: 0x0000, count: 256)
        for i in 0..<table.count {
            var crc: UInt16 = UInt16(i) << 8
            for _ in 0..<8 {
                crc = (crc << 1) ^ ((crc & 0x8000) == 0x8000 ? polynomial : 0)
            }
            table[i] = crc
        }
        self.table = table
    }
    func calculate(_ data: Data) -> UInt16 {
        return calculate(data, seed: nil)
    }
    func calculate(_ data: Data, seed: UInt16?) -> UInt16 {
        var crc: UInt16 = seed ?? 0x0000
        for i in 0..<data.count {
            crc = (crc << 8) ^ table[Int(((crc >> 8) ^ (UInt16(data[i]))) & 0xff)]
        }
        return crc
    }
}
extension CRC16: CustomStringConvertible {
    // MARK: CustomStringConvertible
    var description: String {
        return Mirror(reflecting: self).description
    }
}

func crc32(_ data: [UInt8], _ crcPayload: UInt32) -> Bool {
    let crcCalc = CRC32.MPEG2.calculate(Data(bytes: data))
    return crcCalc == crcPayload
}
// https://github.com/shogo4405/HaishinKit.swift/blob/master/Sources/Util/CRC32.swift
final class CRC32 {
    static let MPEG2: CRC32 = CRC32(polynomial: 0x04c11db7)
    let table: [UInt32]
    init(polynomial: UInt32) {
        var table: [UInt32] = [UInt32](repeating: 0x00000000, count: 256)
        for i in 0..<table.count {
            var crc: UInt32 = UInt32(i) << 24
            for _ in 0..<8 {
                crc = (crc << 1) ^ ((crc & 0x80000000) == 0x80000000 ? polynomial : 0)
            }
            table[i] = crc
        }
        self.table = table
    }
    func calculate(_ data: Data) -> UInt32 {
        return calculate(data, seed: nil)
    }
    func calculate(_ data: Data, seed: UInt32?) -> UInt32 {
        var crc: UInt32 = seed ?? 0xffffffff
        for i in 0..<data.count {
            crc = (crc << 8) ^ table[Int(((crc >> 24) ^ (UInt32(data[i]))) & 0xff)]
        }
        return crc
    }
}
extension CRC32: CustomStringConvertible {
    // MARK: CustomStringConvertible
    var description: String {
        return Mirror(reflecting: self).description
    }
}
