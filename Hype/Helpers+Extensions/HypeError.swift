//
//  HypeError.swift
//  Hype
//
//  Created by Harrison Kleiman on 5/25/22.
//

import Foundation

enum HypeError: LocalizedError {
    case ckError(Error)
    case couldNotUnwrap
    case unexpectedRecordsFound
    
    var errorDescription: String {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .couldNotUnwrap:
            return "Unable to get this Hype, That's not very Hype..."
        case .unexpectedRecordsFound:
            return "Unexpected records were returned when trying to delete"
        }
    }
}
