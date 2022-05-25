//
//  Hype.swift
//  Hype
//
//  Created by Harrison Kleiman on 5/25/22.
//

import Foundation
import CloudKit

struct HypeStrings {
    static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
}

class Hype {
    
    var body: String
    var timestamp: Date
    var recordID: CKRecord.ID
    
    init(body: String, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.body = body
        self.timestamp = timestamp
        self.recordID = recordID
    }
}

extension Hype {
    /**
     Taking retrieved CkRecord & pulling out values found to initialize our Hype model
     */
    convenience init?(ckRecord: CKRecord) {
        guard let body = ckRecord[HypeStrings.bodyKey] as? String,
              let timestamp = ckRecord[HypeStrings.timestampKey] as? Date
        else { return nil }
        
        self.init(body: body, timestamp: timestamp, recordID: ckRecord.recordID)
    }
}

extension Hype: Equatable {
    static func == (lhs: Hype, rhs: Hype) -> Bool {
        return lhs.recordID == rhs.recordID /// lhs === rhs
    }
}

extension CKRecord {
    /**
     Packaging Hype model properties to be stored in CKRecord & saved to cloud
     */
    convenience init(hype: Hype) {
        self.init(recordType: HypeStrings.recordTypeKey, recordID: hype.recordID) ///Access outside of struct
        self.setValuesForKeys([
            HypeStrings.bodyKey : hype.body,
            HypeStrings.timestampKey : hype.timestamp
        ])
    }
}
