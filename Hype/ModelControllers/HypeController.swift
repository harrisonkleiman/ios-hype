//
//  HypeController.swift
//  Hype
//
//  Created by Harrison Kleiman on 5/25/22.
//

import Foundation
import CloudKit

class HypeController {
    
    typealias fetchAllHypes = (Result<[Hype]?, HypeError>) -> Void
    /// Shared instance
    static let shared = HypeController()
    /// Source of Truth array
    var hypes: [Hype] = []
    /// Constant to access our publicCloudDatabase
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - CRUD
    
    func saveHype(with text: String, completion: @escaping (Result<Hype?, HypeError>) -> Void) {
            // Inititialize a Hype object with the text value passed in as a parameter
            let newHype = Hype(body: text)
            // Initialize a CKRecord from the Hype object to be saved in CloudKit
            let hypeRecord = CKRecord(hype: newHype)
            // Call the CKContainer's save method on the database
            publicDB.save(hypeRecord) { (record, error) in
                // Handle the optional error
                if let error = error {
                    return completion(.failure(.ckError(error)))
                }
                // Unwrap the CKRecord that was saved
                guard let record = record,
                    // Re-create the same Hype object from that record that we know was saved
                    let savedHype = Hype(ckRecord: record)
                    else { return completion(.failure(.couldNotUnwrap)) }
                print("Saved Hype successfully")
                // Complete with success
                completion(.success(savedHype))
            }
        }
        
        /**
         Fetches all Hypes stored in the CKContainer's publicDataBase
         
         - Parameters:
            - completion: Escaping completion block for the method
            - result: Result found in the completion block with success returning an array of Hype objects and failure returning a HypeError
         */
    func fetchAllHypes(completion: @escaping (Result<[Hype]?, HypeError>) -> Void) {
            // Step 3 - Create the Predicate needed for the query parameters
            let predicate = NSPredicate(value: true)
            // Step 2 - Create the query needed for the perform(query) method
            let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: predicate)
            // Step 1 - Access the perform(query) method on the database
            publicDB.perform(query, inZoneWith: nil) { (records, error) in
                // Handle the optional error
                if let error = error {
                    print(error.localizedDescription)
                    print("\n\n\n Error: \(error) \n\n\n")
                    return completion(.failure(.ckError(error)))
                }
                // Unwrap the found CKRecord objects
                guard let records = records else { return completion(.failure(.couldNotUnwrap)) }
                print("Fetched Hypes successfully")
                // Map through the found records, appling the Hype(ckRecord:) convenience init method as the transform
                let hypes = records.compactMap({ Hype(ckRecord: $0) })
                // Complete with success
                completion(.success(hypes))
            }
        }
        
    
    // MARK: - UPDATE
    func updateHypes(_ hype: Hype, completion: @escaping (Result<Hype?, HypeError>) -> Void) {
            // Step 2.a Create the record to save (update)
            let record = CKRecord(hype: hype)
            // Step 2 - Create the operation
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            // Step 3 - Adjust the properties for the operation
            operation.savePolicy = .changedKeys
            operation.qualityOfService = .userInteractive
            operation.modifyRecordsCompletionBlock = { (records, _, error) in
                // Handle the optional error
                if let error = error {
                    return completion(.failure(.ckError(error)))
                }
                // Unwrap the record that was updated and complete true
                guard let record = records?.first,
                    let updatedHype = Hype(ckRecord: record)
                    else { completion(.failure(.couldNotUnwrap)) ; return }
                print("Updated \(record.recordID) successfully in CloudKit")
                completion(.success(updatedHype))
            }
            // Step 1 - Add the operation to the database
            publicDB.add(operation)
        }
    
    // MARK: - DELETE
    func deleteHypes(_ hype: Hype, completion: @escaping (Result<Bool, HypeError>) -> Void) {
            // Step 2 - Declare the operation
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.recordID])
        // Step 3 - Set the properties on the operation
            operation.savePolicy = .changedKeys
            operation.qualityOfService = .userInteractive
            
        operation.modifyRecordsCompletionBlock = {records, _, error in
                if let error = error {
                    return completion(.failure(.ckError(error)))
                }
               
                if records?.count == 0 {
                    print("Deleted record from CloudKit")
                    completion(.success(true))
                } else {
                    return completion(.failure(.unexpectedRecordsFound))
                }
            }
            
            publicDB.add(operation)
        }
        
       
    func subscribeForRemoteNotifications(completion: @escaping (Error?) -> Void) {
        // Step 3 - declare requisite predicate
        let predicate = NSPredicate(value: true)
        // Step 2 - Declare the subscription
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        
        // Step 4 - Setting the sunscription properties
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "HELLO I AM ALERTING YOU :D"
        notificationInfo.alertBody = "CHOO CHOO THIS IS THE HYPE TRAIN"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        // Step 1 - Call subscription function on DB
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }
} // End of class

