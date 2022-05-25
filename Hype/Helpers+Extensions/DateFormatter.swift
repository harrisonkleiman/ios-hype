//
//  DateFormatter.swift
//  Hype
//
//  Created by Harrison Kleiman on 5/25/22.
//

import Foundation

extension Date {
    
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
}
