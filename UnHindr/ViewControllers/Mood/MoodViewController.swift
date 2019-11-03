//
//  MoodViewController.swift
//  UnHindr
//
//  Created by Sina Ahmadian Behrouz on 11/1/19.
//  Copyright © 2019 Sigma. All rights reserved.
//

import UIKit

class MoodViewController: UIViewController {
    // Private variables to keep track of scores
    private var score = 0
    
    // Outlets for buttons
    @IBOutlet weak var StronglyAgree: UIButton!
    @IBOutlet weak var AgreeButton: UIButton!
    @IBOutlet weak var NuetralButton: UIButton!
    @IBOutlet weak var DisagreeButton: UIButton!
    @IBOutlet weak var StronglyDisagreeButton: UIButton!
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        clearAllButtonBackgrounds()
    }
    
    
    // MARK: - Visual effects on the choice buttons
    // Backend Function
    // Input: None
    // Output:
    //      1.The choice buttons now contain a white background
    func clearAllButtonBackgrounds(){
        StronglyAgree.backgroundColor = UIColor.white
        AgreeButton.backgroundColor = UIColor.white
        NuetralButton.backgroundColor = UIColor.white
        DisagreeButton.backgroundColor = UIColor.white
        StronglyDisagreeButton.backgroundColor = UIColor.white
    }
    
    // MARK: - Button actions for selecting mood options
    // Action:
    //      1. On tap
    // Output:
    //      1. Border highlight around strongly agree
    @IBAction func stronglyAgreeTapped(_ sender: UIButton) {
        score = 5
        clearAllButtonBackgrounds()
        StronglyAgree.backgroundColor = UIColor.lightGray
    }
    
    // Action:
    //      1. On tap
    // Output:
    //      1. Border highlight around agree
    @IBAction func agreeTapped(_ sender: UIButton) {
        score = 4
        clearAllButtonBackgrounds()
        AgreeButton.backgroundColor = UIColor.lightGray
    }
    
    // Action:
    //      1. On tap
    // Output:
    //      1. Border highlight around neutral
    @IBAction func neutralTapped(_ sender: UIButton) {
        score = 3
        clearAllButtonBackgrounds()
        NuetralButton.backgroundColor = UIColor.lightGray
    }
    
    // Action:
    //      1. On tap
    // Output:
    //      1. Border highlight around disagree
    @IBAction func disagreeTapped(_ sender: UIButton) {
        score = 2
        clearAllButtonBackgrounds()
        DisagreeButton.backgroundColor = UIColor.lightGray
    }
    
    // Action:
    //      1. On tap
    // Output:
    //      1. Border highlight around strongly disagree
    @IBAction func stronglyDisagreeTapped(_ sender: UIButton) {
        score = 1
        clearAllButtonBackgrounds()
        StronglyDisagreeButton.backgroundColor = UIColor.lightGray
    }
    
    // Action:
    //      1. On tap
    // Output:
    //      1. store data to database
    //      2. Return to home screen
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if(self.score != 0){
            performSegue(withIdentifier: "Q1ToQ2", sender: self)
        }
    }
    
    // MARK: - Segue to transition to next controller
    // Input: None
    // Output:
    //      1. Q2 view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "Q1ToQ2"){
            let vc = segue.destination as! MoodQ2ViewController
            vc.prevScore = self.score
        }
    }
}
