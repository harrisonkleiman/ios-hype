//
//  UserError.swift
//  Hype
//
//  Created by Harrison Kleiman on 5/25/22.
//

import Foundation

enum UserError: Error {
    case ckError(Error)
    case couldNotUnwrap
    case unexpectedRecordsFound
    case noUserLoggedIn
    
    var errorDescription: String {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .couldNotUnwrap:
            return ""
        case .unexpectedRecordsFound:
            return ""
        case .noUserLoggedIn:
            return ""
        }
    }
}
