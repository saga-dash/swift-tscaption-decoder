//
//  XCTestManifests.swift
//  TSCaptionDecoder
//
//  Created by saga-dash on 2018/07/10.
//

import XCTest

#if !os(macOS)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(CommonTests.allTests),
            testCase(TransportPacketTests.allTests),
        ]
    }
#endif
