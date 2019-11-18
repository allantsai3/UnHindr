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
    
    // Reference to all users
    static let fullUserRef = db.collection("users")
    
    // User profile reference
    static let userProfileRef = db.collection("users").document(userRef!)
    
    // Medication plan reference
    static let medicationPlanRef = db.collection("users").document(userRef!).collection("MedicationPlan")
    
    // Medication history reference
    static let medicationHistoryRef = db.collection("users").document(userRef!).collection("Medication")
    
    static let motorGameRef = db.collection("users").document(userRef!).collection("MotorGameData")
    // Connections reference
    static let connectionRef = db.collection("users").document(userRef!).collection("Connections")
    
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
    //Configures how the alert will be displayed to screen
    //input:
    //      1.Takes in a title and message parameter and displays alert to screen
    //output:
    //      1. output the alert to the screen
    static func showAlert(_ title:String, _ message: String, vc: UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(alertAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func transitionHome(_ UIVC: UIViewController){
        Services.fetchModeStatus(Services.userRef!) { (result) in
            if (result!) {
                let storyboard = UIStoryboard(name: "HomeScreen", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as UIViewController
                UIVC.present(vc, animated: true, completion: nil)
            }else{
                let storyboard = UIStoryboard(name: "CaregiverHomeScreen", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "CaregiverHomeScreenViewController") as UIViewController
                UIVC.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    
    
    // Fetch caregiver mode status using a completion handler
    // Input:
    //      1. User reference
    // Output:
    //      1. returns true if user is a patient else false
    static func fetchModeStatus(_ userdoc: String, completionHandler: @escaping (_ result: Bool? ) -> Void){
        Services.userProfileRef.getDocument { (documentSnapshot, err) in
            if err != nil {
                //error
            }
            else{
                guard let document = documentSnapshot else {
                    print("Error fetching user document")
                    return
                }
                
                let status = document.get("isPatient") as! Bool

                completionHandler(status)
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
