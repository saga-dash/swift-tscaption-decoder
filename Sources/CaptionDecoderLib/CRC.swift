// 
//  CRC.swift
//  CaptionDecoderLib
//
//  Created by saga-dash on 2018/07/14.
//


import Foundation

// https://github.com/LimChihi/CRC16/blob/master/CRC16/CRC16.swift
//CRC-16-CCITT x^{{16}}+x^{{12}}+x^{5}+1
fileprivate let gPloy = 0x1021
fileprivate var crcTable: [Int] = []
fileprivate func getCrcOfByte(aByte: Int) -> Int {
    var value = aByte << 8
    for _ in 0 ..< 8 {
        if (value & 0x8000) != 0 {
            value = (value << 1) ^ gPloy
        }else {
            value = value << 1
        }
    }
    
    value = value & 0xFFFF //get low 16 bit value
    
    return value
}
func crc16(_ data: [UInt8]) -> UInt16? {
    if crcTable.count == 0 {
        for i in 0..<256 {
            crcTable.append(getCrcOfByte(aByte: i))
        }
    }
    var crc = 0
    let dataInt: [Int] = data.map{Int( $0) }
    
    let length = data.count
    
    for i in 0 ..< length {
        crc = ((crc & 0xFF) << 8) ^ crcTable[(((crc & 0xFF00) >> 8) ^  dataInt[i]) & 0xFF]
    }
    
    crc = crc & 0xFFFF
    return UInt16(crc)
}


