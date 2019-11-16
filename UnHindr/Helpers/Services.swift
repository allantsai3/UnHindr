/*
 File: [Services.swift]
 Creators: [Allan]
 Date created: [29/10/2019]
 Date updated: [10/11/2019]
 Updater name: [Allan]
 File description: [Services file for database references]
 */

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth


class Services {
    
    // Store reference to current user's stored data
    static var userRef: String?
    
    // Handle for authentication changes
    static var handle: AuthStateDidChangeListenerHandle?
    
    // Static reference to Firestore root
    static let db = Firestore.firestore()
    
    // User profile reference
    static let userProfileRef = db.collection("users").document(userRef!)
    
    // Medication plan reference
    static let medicationPlanRef = db.collection("users").document(userRef!).collection("MedicationPlan")
    
    // Medication history reference
    static let medicationHistoryRef = db.collection("users").document(userRef!).collection("Medication")
    
    // MARK: - Retrieve reference to a patient's data
    // Input:
    //      1. unique UID of a user
    // Output:
    //      1. Reference to user data
    static func getDBUserRef(_ user: User?, completionHandler: @escaping(_ result: String?) -> Void) {
        var result: String!
        // fetch reference to specified user
        let uid = (user?.uid ?? "User instance is nil")
        db.collection("users").whereField("uid", isEqualTo: uid)
            .getDocuments() { (querySnapshot, err) in
                if err != nil {
                    print("Error getting user info")
                } else {
                    result = (querySnapshot!.documents[0].documentID)
                    completionHandler(result)
                }
        }
    }
    
}

extension Date {
    enum Weekday: String, CaseIterable {
        case Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
        
        static var asArray: [Weekday] {
            return self.allCases
        }
        
        func asInt() -> Int {
            return Weekday.asArray.firstIndex(of: self)!
        }
    }
    
    static func isToday(_ timestamp: Timestamp) -> Bool {
        return Calendar.current.isDateInToday(timestamp.dateValue())
    }
    
    static func getDayOfWeek(_ timestamp: Timestamp) -> Date.Weekday {
        // Get date of week from NSDate value
        print("Timestamp: \(timestamp.dateValue())")
        let index = Calendar.current.component(.weekday, from: timestamp.dateValue())
        print("Date of week \(index)")
        return Weekday.asArray[index-1]
    }
    
}
