//
//  XCTestManifests.swift
//  ByteArrayWrapper
//
//  Created by saga-dash on 2018/08/12.
//

import XCTest

#if !os(macOS)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(CommonTests.allTests),
        ]
    }
#endif
