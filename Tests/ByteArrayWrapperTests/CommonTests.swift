//
//  CommonTests.swift
//  ByteArrayWrapper
//
//  Created by saga-dash on 2018/08/12.
//

import XCTest
import Foundation
@testable import ByteArrayWrapper

extension CommonTests {
    static var allTests : [(String, (CommonTests) -> () throws -> Void)] {
        return [
            ("testTake", testTake),
            ("testSkip", testSkip),
            ("testGet", testGet),
            ("testSetIndex", testSetIndex),
        ]
    }
}

final class CommonTests: XCTestCase {
    override func setUp() {
    }
    func testClone() throws {
        let bytes: [UInt8] = [1, 2, 3, 4, 5, 6]
        let wrapper = ByteArray(bytes)
        let clone = wrapper.clone()
        _ = try wrapper.get(num: 3)
        _ = try clone.get(num: 2)
        XCTAssertNotEqual(wrapper.getIndex(), clone.getIndex())
    }
    func testCount() throws {
        let bytes: [UInt8] = [1, 2, 3, 4, 5, 6]
        let wrapper = ByteArray(bytes)
        XCTAssertEqual(6, wrapper.count)
        _ = try wrapper.take(3)
        XCTAssertEqual(3, wrapper.count)
    }
    func testTake() throws {
        let bytes: [UInt8] = [1, 2, 3, 4, 5, 6]
        let wrapper = ByteArray(bytes)
        XCTAssertEqual([1, 2, 3,], try wrapper.take(3))
        XCTAssertEqual([4, 5,], try wrapper.take(2))
        XCTAssertThrowsError(try wrapper.take(0)) { error in
            print("invalidArgument", error)
            XCTAssertTrue(error is ByteArrayError)
        }
        XCTAssertThrowsError(try wrapper.take(2)) { error in
            print("outOfRange", error)
            XCTAssertTrue(error is ByteArrayError)
        }
        XCTAssertEqual([6,], try wrapper.take())
        XCTAssertThrowsError(try wrapper.take(1)) { error in
            print("outOfRange", error)
            XCTAssertTrue(error is ByteArrayError)
        }
    }
    func testSkip() throws {
        let bytes: [UInt8] = [1, 2, 3, 4, 5, 6]
        let wrapper = ByteArray(bytes)
        try wrapper.skip(3)
        XCTAssertThrowsError(try wrapper.skip(-1)) { error in
            print("invalidArgument", error)
            XCTAssertTrue(error is ByteArrayError)
        }
        try wrapper.skip(0)
        XCTAssertThrowsError(try wrapper.skip(200)) { error in
            print("outOfRange", error)
            XCTAssertTrue(error is ByteArrayError)
        }
        XCTAssertEqual([4, 5,], try wrapper.take(2))
    }
    func testGet() throws {
        let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06]
        let wrapper = ByteArray(bytes)
        XCTAssertEqual(0x01 , try wrapper.get(doMove: false) as UInt8)
        XCTAssertEqual(0x01 , try wrapper.get() as UInt8)
        XCTAssertThrowsError(try wrapper.get(num: 200)) { error in
            print("outOfRange", error)
            XCTAssertTrue(error is ByteArrayError)
        }
        XCTAssertEqual(0x0203 , try wrapper.get(num: 2) as UInt64)
        XCTAssertEqual(0x040506 , try wrapper.get(num: 3) as UInt64)
        XCTAssertThrowsError(try wrapper.get()) { error in
            print("outOfRange", error)
            XCTAssertTrue(error is ByteArrayError)
        }
    }
    func testSetIndex() throws {
        let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06]
        let wrapper = ByteArray(bytes)
        XCTAssertEqual(0x0102 , try wrapper.get(num: 2) as UInt64)
        XCTAssertThrowsError(try wrapper.setIndex(-1)) { error in
            print("invalidArgument", error)
            XCTAssertTrue(error is ByteArrayError)
        }
        XCTAssertThrowsError(try wrapper.setIndex(200)) { error in
            print("outOfRange", error)
            XCTAssertTrue(error is ByteArrayError)
        }
        try wrapper.setIndex(1)
        XCTAssertEqual(1 , wrapper.getIndex())
    }
}
