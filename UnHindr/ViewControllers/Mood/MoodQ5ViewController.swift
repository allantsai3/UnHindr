//
//  MoodQ5ViewController.swift
//  UnHindr
//
//  Created by Sina Ahmadian Behrouz on 11/1/19.
//  Copyright © 2019 Sigma. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase

class MoodQ5ViewController: UIViewController {
    // Private variables to keep track of scores
    private var score = 0
    var prevScore = 0
    
    // Store user object from authentication
    private var user: User?
    
    // Outlets for buttons
    @IBOutlet weak var SAB: UIButton!
    @IBOutlet weak var AB: UIButton!
    @IBOutlet weak var NB: UIButton!
    @IBOutlet weak var DB: UIButton!
    @IBOutlet weak var SDB: UIButton!
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.score = self.prevScore
        clearAllButtonBackgrounds()
        
        // Create authentication listeneing handler
        Services.handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user != nil {
                self.user = user
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Delete authentication handler
        Auth.auth().removeStateDidChangeListener(Services.handle!)
    }
    
    // MARK: - Visual effects on the choice buttons
    // Backend Function
    // Input: None
    // Output:
    //      1.The choice buttons now contain a white background
    func clearAllButtonBackgrounds(){
        SAB.backgroundColor = UIColor.white
        AB.backgroundColor = UIColor.white
        NB.backgroundColor = UIColor.white
        DB.backgroundColor = UIColor.white
        SDB.backgroundColor = UIColor.white
    }
    
    // MARK: - Button actions for selecting mood options
    // Action:
    //      1. On tap
    // Output:
    //      1. Border highlight around strongly agree
    @IBAction func stronglyAgreeTapped(_ sender: UIButton) {
        score = prevScore + 5
        clearAllButtonBackgrounds()
        SAB.backgroundColor = UIColor.lightGray
    }
    
    // Action:
    //      1. On tap
    // Output:
    //      1. Border highlight around agree
    @IBAction func agreeTapped(_ sender: UIButton) {
        score = prevScore + 4
        clearAllButtonBackgrounds()
        AB.backgroundColor = UIColor.lightGray
    }
    
    // Action:
    //      1. On tap
    // Output:
    //      1. Border highlight around neutral
    @IBAction func neutralTapped(_ sender: UIButton) {
        score = prevScore + 3
        clearAllButtonBackgrounds()
        NB.backgroundColor = UIColor.lightGray
    }
    
    // Action:
    //      1. On tap
    // Output:
    //      1. Border highlight around disagree
    @IBAction func disagreeTapped(_ sender: UIButton) {
        score = prevScore + 2
        clearAllButtonBackgrounds()
        DB.backgroundColor = UIColor.lightGray
    }
    
    // Action:
    //      1. On tap
    // Output:
    //      1. Border highlight around strongly disagree
    @IBAction func stronglyDisagreeTapped(_ sender: UIButton) {
        score = prevScore + 1
        clearAllButtonBackgrounds()
        SDB.backgroundColor = UIColor.lightGray
    }
    
    // MARK: - Store mood score to the database
    // Input:
    //      1. averaged score
    // Output:
    //      1. saved to database
    func storeToDB(toSave: Double){
        //User should be logged in with reference created
        
        // Add a new document with a generated id.
                
        var ref: DocumentReference? = nil
        ref = Services.db.collection("users").document(Services.userRef).collection("Mood").addDocument(data: [
            "Date": Timestamp(date: Date()),
            "Score": toSave
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    // MARK - Changes storyboard and view controller to the home screen
    // Input: None
    // Output:
    //      1. Storyboard changes to HomeScreen and displays first view on the storyboard
    func goToHomeScreen(){
        let storyboard = UIStoryboard(name: "HomeScreen", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as UIViewController
        present(vc, animated: true, completion: nil)
        
    }
    
    // Action:
    //      1. On tap
    // Output:
    //      1. store data to database
    //      2. Return to home screen
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if(self.score != self.prevScore){
            let toStore = Double(self.score) / 5.0
            storeToDB(toSave: toStore)
            goToHomeScreen()
        }
        
    }
    
    // Action:
    //      1. On tap
    // Output:
    //      1. Return to previous question
    @IBAction func backButtonTapped(_ sender: UIButton) {
          performSegue(withIdentifier: "Q5ToQ4", sender: self)
    }
    

}
