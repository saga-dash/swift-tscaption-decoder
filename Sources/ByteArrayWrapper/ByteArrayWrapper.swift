// 
//  ByteArrayWrapper.swift
//  ByteArrayWrapper
//
//  Created by saga-dash on 2018/08/12.
//


import Foundation

public class ByteArray {
    let bytes: [UInt8]
    var index: Int
    public init(_ bytes: [UInt8], _ index: Int = 0) {
        self.bytes = bytes
        self.index = index
    }
    public func clone() -> ByteArray {
        return ByteArray(bytes, index)
    }
    public func take(_ num: Int? = nil) throws -> [UInt8] {
        guard let num = num else {
            defer {
                index = bytes.count
            }
            return Array(bytes[index..<bytes.count])
        }
        if num < 1 {
            throw ByteArrayError.invalidArgument("引数は1以上を指定")
        }
        if bytes.count < index + num {
            throw ByteArrayError.outOfRange()
        }
        defer {
            index += num
        }
        return Array(bytes[index..<index+num])
    }
    public func skip(_ num: Int) throws {
        if num < 1 {
            throw ByteArrayError.invalidArgument("引数は1以上を指定")
        }
        if bytes.count < index + num {
            throw ByteArrayError.outOfRange()
        }
        defer {
            index += num
        }
    }
    public func get(doMove: Bool = true) throws -> UInt8 {
        if bytes.count < index + 1 {
            throw ByteArrayError.outOfRange()
        }
        let result = bytes[index]
        if doMove {
            index += 1
        }
        return result
    }
    public func get(num: Int) throws -> UInt64 {
        if bytes.count < index + num || 8 < num {
            throw ByteArrayError.outOfRange()
        }
        var result: UInt64 = 0
        for _ in 0..<num {
            result = result<<8 | UInt64(bytes[index])
            index += 1
        }
        return result
    }
    public func getIndex() -> Int {
        return index
    }
    public func setIndex(_ index: Int) throws {
        if index < 0 {
            throw ByteArrayError.invalidArgument("引数は0以上を指定")
        }
        if bytes.count < index {
            throw ByteArrayError.outOfRange()
        }
        self.index = index
    }
}
