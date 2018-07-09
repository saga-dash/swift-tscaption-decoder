//
//  LinuxMain.swift
//  CaptionDecoder
//
//  Created by saga-dash on 2018/07/10.
//

import XCTest
import CaptionDecoderTests

var tests = [XCTestCaseEntry]()

tests += CommonTests.allTests()
tests += TransportPacketTests.allTests()

XCTMain(tests)
