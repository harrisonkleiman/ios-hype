//
//  User.swift
//  Hype
//
//  Created by Harrison Kleiman on 5/25/22.
//

import Foundation
import CloudKit

struct UserStrings {
    static let recordTypeKey = "User"
    fileprivate static let usernameKey = "username"
    fileprivate static let bioKey = "bio"
    static let appleUserRefKey = "appleUserRef"
}

class User {
    var username: String
    var bio: String
    var recordID: CKRecord.ID
    var appleUserRef: CKRecord.Reference
    
    init(username: String, bio: String = "", recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserReference: CKRecord.Reference) {
        self.username = username
                self.bio = bio
                self.recordID = recordID
                self.appleUserRef = appleUserReference
    }
}
