//
//  main.swift
//  TSCaptionDecoder
//
//  Created by saga-dash on 2018/07/05.
//


import Foundation
import Commander

import TSCaptionDecoderLib

#if os(Linux)
func autoreleasepool(_ code: () -> ()) {
    code()
}
#endif

extension StreamComponentTag : ArgumentConvertible {
    public init(parser: ArgumentParser) throws {
        switch parser.shift() {
        case "subtitle":
            self = .subtitle
        case "subtitle1":
            self = .subtitle1
        case "subtitle2":
            self = .subtitle2
        case "subtitle3":
            self = .subtitle3
        case "subtitle4":
            self = .subtitle4
        case "subtitle5":
            self = .subtitle5
        case "subtitle6":
            self = .subtitle6
        case "subtitle7":
            self = .subtitle7
        case "teletext":
            self = .teletext
        case "teletext1":
            self = .teletext1
        case "teletext2":
            self = .teletext2
        case "teletext3":
            self = .teletext3
        case "teletext4":
            self = .teletext4
        case "teletext5":
            self = .teletext5
        case "teletext6":
            self = .teletext6
        case "teletext7":
            self = .teletext7
        default:
            self = .subtitle
        }
    }
    public var description: String {
        return "\(String(format: "0x%02x", self.rawValue))"
    }
}

let main = command(
    Option<String>("file", default: "", flag: "f"),
    Option<StreamComponentTag>("componentTag", default: .subtitle, flag: "c", description: "subtitle, subtitle{1-7}, teletext, teletext{1-7}")) { inputFile, streamComponentTag in
    let options = Options(streamComponentTag)
    var file: FileHandle
    if inputFile.count != 0 {
        file = FileHandle.init(forReadingAtPath: inputFile)!
    } else {
        file = FileHandle.standardInput
    }
    while true {
        autoreleasepool {
            let data = file.readData(ofLength: LENGTH)
            if data.count != LENGTH {
                exit(-1)
            }
            do {
                let _ = try TSCaptionDecoderSub(data: data, options: options)
                let result = try TSCaptionDecoderMain(data: data, options: options)
                for unit in result {
                    //print(unit.str)
                    let encoder = JSONEncoder()
                    let encoded = try! encoder.encode(unit)
                    print(String(data: encoded, encoding: .utf8)!)
                    fflush(stdout)
                }
            } catch {
                print("\(error)")
                fflush(stdout)
            }
        }
    }
}

main.run()

