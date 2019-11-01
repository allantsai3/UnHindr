//
//  HomeScreenViewController.swift
//  UnHindr
//
//  Created by ata87 on 10/31/19.
//  Copyright © 2019 Sigma. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeScreenViewController : UIViewController {
    
    // Handler for the auth state listener
    private var handle: AuthStateDidChangeListenerHandle?
    
    
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Start auth listener
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            self.setDisplayName(user)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    private func setDisplayName(_ user: User?){
        let uid = user?.uid ?? "User instance is nil"
        //Retrieve first and last name
        let db = Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting document: \(err)")
                } else {
                    // should only have 1 document
                    for document in querySnapshot!.documents {
                        let firstName = (document.get("firstName") ?? "" ) as? String
                        let lastName = (document.get("lastName") ?? "") as? String
                        let name = firstName! + " " + lastName!
                        self.nameLabel.text = name
//                        print("\(document.documentID) => \(document.data())")
//                        print(document.get("lastName") ?? "")
                    }
                }
        }
    }
    
}
