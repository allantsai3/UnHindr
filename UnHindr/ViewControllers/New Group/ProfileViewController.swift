//
//  ProfileViewController.swift
//  UnHindr
//
//  Created by Sina Ahmadian Behrouz on 11/2/19.
//  Copyright © 2019 Sigma. All rights reserved.
//

import UIKit
import Foundation
import FirebaseFirestore
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    private var datacollection: [String: Any]? = [:]
    var FirstName = "Jack"
    var LastName = "Huncho"
    var Email = "JH@google.com"
    var Dob = DateComponents(calendar: Calendar.current, year: 1990, month: 08, day: 01)
    var gender = 1 //0 female , 1 men , 2 undecided
    var Address = "xxxxx"
    var City = "xxxxxx"
    var Country = "xxxx"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }//view DidLoad()
    
    override func viewWillAppear(_ animated: Bool) {
        self.getUserInfo(Services.userRef, completionHandler: { (complete) in
            if complete == true {
                self.addressTF.text = self.datacollection!["address"] as? String
                self.FirstNameTF.text = self.datacollection!["firstName"] as? String
                self.lastNameTF.text = self.datacollection!["lastName"] as? String
                self.emailTF.text = self.datacollection!["email"] as? String
                
                // Obtain the firebase dob field as a string
                let extractedDob = self.datacollection!["dob"] as! Timestamp
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let convertedDate = formatter.string(from: extractedDob.dateValue())
                let date1 = formatter.date(from: convertedDate)
                formatter.dateFormat = "dd-MMM-yyyy"
                let intuitiveDate = formatter.string(from:date1!)
                self.dobTF.text = intuitiveDate
                
                //determine the gender
                if(self.datacollection!["gender"] as? Int == 0){
                    self.gendreTF.text = "Female"
                }else if (self.datacollection!["gender"] as? Int == 1){
                    self.gendreTF.text = "Male"
                }else{
                    self.gendreTF.text = "Undecided"
                }
            }
            else{
                print("----------------Failed to get user data--------------")
            }
            
        })
    }
    
    @IBOutlet weak var FirstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var dobTF: UITextField!
    @IBOutlet weak var gendreTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var countryTF: UITextField!
    
    // MARK: - Retrieve reference to a patient's data
    // Input:
    //      1. unique UID of a user
    // Output:
    //      1. Reference to user data
    func getUserInfo(_ userdoc: String, completionHandler: @escaping (_ result: Bool? ) -> Void){
        Services.db.collection("users").document(userdoc).addSnapshotListener { (documentSnapshot, error) in
            
            if error != nil {
                //error
            }
            else{
                guard let document = documentSnapshot else {
                    print("Error fetching user document")
                    return
                }
//                self.LastName = document.get("lastName") as! String
//                self.Email = document.get("email") as! String
//                self.FirstName = document.get("firstName") as! String
//                self.Address = document.get("address") as! String
//                self.City = document.get("city") as! String
//                self.Country = document.get("coquitlam") as! String
                self.datacollection = document.data()
//                print("Type: \(document.data())")
                
                let result = true
                completionHandler(result)
            }
            
        }
    }
    
    // MARK: - Send flow back to the Home Screen
    // Input: None
    // Output:
    //      1. The user is at the Home Screen now
    @IBAction func backTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "HomeScreen", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as UIViewController
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Update and Store user data
    // Input: None
    // Output:
    //      1. The user's data is persistently stored
    @IBAction func saveTapped(_ sender: UIButton) {
        
    }
    
    // MARK: - Update all the text fields
    // Input: None
    // Output:
    //      1. update all the user text fields
    func updateTextField(){
        //emailTF.text = self.Email
        print("FCK:")
    }
    
}
