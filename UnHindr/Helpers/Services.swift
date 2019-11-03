//
//  Services.swift
//  UnHindr
//
//  Created by Allan on 2019-11-02.
//  Copyright © 2019 Sigma. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth


class Services {
    
    // Store reference to current user's stored data
    static var userRef: String!
    
    // Handle for authentication changes
    static var handle: AuthStateDidChangeListenerHandle?
    
    // Static reference to Firestore root
    static let db = Firestore.firestore()
    
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
