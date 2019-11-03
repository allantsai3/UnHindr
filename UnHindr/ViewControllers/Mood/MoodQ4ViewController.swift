//
//  MoodQ4ViewController.swift
//  UnHindr
//
//  Created by Sina Ahmadian Behrouz on 11/1/19.
//  Copyright © 2019 Sigma. All rights reserved.
//

import UIKit

class MoodQ4ViewController: UIViewController {
    // Private variables to keep track of scores
    private var score = 0
    var prevScore = 0
    
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
    
    // Action:
    //      1. On tap
    // Output:
    //      1. store data to database
    //      2. Return to home screen
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if(self.score != self.prevScore){
            performSegue(withIdentifier: "Q4ToQ5", sender: self)

        }
    }
    
    // Action:
    //      1. On tap
    // Output:
    //      1. Return to previous question
    @IBAction func backButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "Q4ToQ3", sender: self)

    }
    
    // MARK: - Segue to transition to next controller
    // Input: None
    // Output:
    //      1. Q5 view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "Q4ToQ5"){
            let vc = segue.destination as! MoodQ5ViewController
            vc.prevScore = self.score
        }
    }
}
