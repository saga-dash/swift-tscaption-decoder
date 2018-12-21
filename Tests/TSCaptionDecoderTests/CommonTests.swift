//
//  CommonTests.swift
//  TSCaptionDecoder
//
//  Created by saga-dash on 2018/07/10.
//

import XCTest
import Foundation
@testable import TSCaptionDecoderLib

extension CommonTests {
    static var allTests : [(String, (CommonTests) -> () throws -> Void)] {
        return [
        ]
    }
}

final class CommonTests: XCTestCase {
    override func setUp() {
    }
    func testPickAppearanceTime() throws {
        let tsDate = Date()
        let tsDatePcr: [UInt8] = [0xFF, 0xFF, 0xF6, 0x5E, 0x80, 0x00]
        let pcr: [UInt8] = [0x00, 0x00, 0x07, 0xF7, 0x00, 0x00]
        let appearanceTime = pickAppearanceTime(tsDate: tsDate, tsDatePcr: tsDatePcr, pcr: pcr)
        print(appearanceTime)
        print(convertJSTStr(Date.init(timeIntervalSince1970: Double(appearanceTime!))))
    }
}

