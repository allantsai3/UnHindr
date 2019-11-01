//
//  MedicationViewController.swift
//  UnHindr
//
//  Created by Jakeb Puffer  on 10/29/19.
//  Copyright © 2019 Sigma. All rights reserved.
//

import Foundation
import UIKit

class MedicationViewController: UIViewController {

    //let timePicker = UIDatePicker()
    
    @IBOutlet weak var checkMon: UIImageView!
    @IBOutlet weak var checkTues: UIImageView!
    @IBOutlet weak var checkWed: UIImageView!
    @IBOutlet weak var checkThur: UIImageView!
    @IBOutlet weak var checkFri: UIImageView!
    @IBOutlet weak var checkSat: UIImageView!
    @IBOutlet weak var checkSun: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        checkMon.alpha = 0
        checkTues.alpha = 0
        checkWed.alpha = 0
        checkThur.alpha = 0
        checkFri.alpha = 0
        checkSat.alpha = 0
        checkSun.alpha = 0
    }

    @IBAction func monButtonTapped(_ sender: Any) {
        if (checkMon.alpha == 1){
            checkMon.alpha = 0
        }
        else {
            checkMon.alpha = 1
        }
    }
    @IBAction func tuesButtonTapped(_ sender: Any) {
        if (checkTues.alpha == 1){
            checkTues.alpha = 0
        }
        else {
            checkTues.alpha = 1
        }
    }
    @IBAction func wedButtonTapped(_ sender: Any) {
        if (checkWed.alpha == 1){
            checkWed.alpha = 0
        }
        else {
            checkWed.alpha = 1
        }
    }
    @IBAction func thursButtonPressed(_ sender: Any) {
        if (checkThur.alpha == 1){
            checkThur.alpha = 0
        }
        else {
            checkThur.alpha = 1
        }
    }
    @IBAction func friButtonPressed(_ sender: Any) {
        if (checkFri.alpha == 1){
            checkFri.alpha = 0
        }
        else {
            checkFri.alpha = 1
        }
    }
    @IBAction func satButtonPressed(_ sender: Any) {
        if (checkSat.alpha == 1){
            checkSat.alpha = 0
        }
        else {
            checkSat.alpha = 1
        }
    }
    @IBAction func sunButtonPressed(_ sender: Any) {
        if (checkSun.alpha == 1){
            checkSun.alpha = 0
        }
        else {
            checkSun.alpha = 1
        }
    }
    @IBAction func addMedTapped(_ sender: Any) {
        //send data
    }
    @IBAction func cancelMedTapped(_ sender: Any) {
        //go back to med screen
    }
    @IBOutlet weak var dosageLabel: UILabel!
    @IBAction func dosageStepper(_ sender: UIStepper) {
        dosageLabel.text = String(Int(sender.value))
    }
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBAction func quantityStepper(_ sender: UIStepper) {
        quantityLabel.text = String(Int(sender.value))
    }
}

    
    
    // @IBAction func timeButtonPressed(_ sender: Any) {
        /*timePicker.datePickerMode = .time
        timePicker.frame = CGRect(x: 0.0, y: (self.view.frame.height/2 + 60), width: self.view.frame.width, height: 150.0)
        timePicker.backgroundColor = UIColor.white
        self.view.addSubview(timePicker)
        timePicker.addTarget(self, action: #selector(MedicationViewController.timeChanged), for: UIControl.Event.valueChanged)*/
    //}
   // @objc func timeChanged(sender: UIDatePicker) {
    //    let formatter = DateFormatter()
     //   formatter.timeStyle = .short
        //timeButtonPressed = formatter.string(from: sender.date)
    //    timePicker.removeFromSuperview() // if you want to remove time picker
    //}//
//}
