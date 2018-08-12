// 
//  ByteArrayError.swift
//  ByteArrayWrapper
//
//  Created by saga-dash on 2018/08/12.
//


import Foundation

public enum ByteArrayError : Error {
    case outOfRange()
    case invalidArgument(String)
    case internalError(String)
}

extension ByteArrayError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidArgument(let message):
            return "\(message)"
        case .internalError(let message):
            return "\(message)"
        default:
            return ""
        }
    }
}
