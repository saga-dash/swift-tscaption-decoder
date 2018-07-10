//
//  main.swift
//  swift-caption-decoder
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation
import CaptionDecoderLib

let env = ProcessInfo.processInfo.environment
var file: FileHandle
if let filepath = env["TS_FILE_PATH"] {
    file = FileHandle.init(forReadingAtPath: filepath)!
} else {
    file = FileHandle.standardInput
}

#if os(Linux)
func autoreleasepool(_ code: () -> ()) {
    code()
}
#endif

while true {
    autoreleasepool {
        let data = file.readData(ofLength: LENGTH)
        if data.count != LENGTH {
            exit(-1)
        }
        let result = CaptionDecoderMain(data: data)
        for unit in result {
            print(unit.str)
            fflush(stdout)
        }
    }
}
