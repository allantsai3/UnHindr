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

    
    
    @IBOutlet weak var checkMon: UIImageView!
    @IBOutlet weak var checkTues: UIImageView!
    @IBOutlet weak var checkWed: UIImageView!
    @IBOutlet weak var checkThur: UIImageView!
    @IBOutlet weak var checkFri: UIImageView!
    @IBOutlet weak var checkSat: UIImageView!
    @IBOutlet weak var checkSun: UIImageView!

    @IBOutlet weak var medFieldName: UITextField!
    
    private var timePicker: UIDatePicker?
    
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
        
        configureMedNameText()
        configureTapGesture()
        
        timePicker = UIDatePicker()
        timePicker?.datePickerMode = .time
        timePicker?.addTarget(self, action: #selector(MedicationViewController.timeChanged(timePicker:)), for: .valueChanged)
        
        timeInputTextField.inputView = timePicker
    }
    

    
    @objc func timeChanged(timePicker: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        timeInputTextField.text = timeFormatter.string(from: timePicker.date)
    }
    
    @IBOutlet weak var timeInputTextField: UITextField!
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MedicationViewController.handleTapOutsideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func handleTapOutsideKeyboard() {
        view.endEditing(true)
    }
    
    private func configureMedNameText(){
        medFieldName.delegate = self
    }
    @IBAction func monButtonTapped(_ sender: Any) {
        if (checkMon.alpha == 1){
            checkMon.alpha = 0
        }
        else {
            checkMon.alpha = 1
        }
        view.endEditing(true)
    }
    @IBAction func tuesButtonTapped(_ sender: Any) {
        if (checkTues.alpha == 1){
            checkTues.alpha = 0
        }
        else {
            checkTues.alpha = 1
        }
        view.endEditing(true)
    }
    @IBAction func wedButtonTapped(_ sender: Any) {
        if (checkWed.alpha == 1){
            checkWed.alpha = 0
        }
        else {
            checkWed.alpha = 1
        }
        view.endEditing(true)
    }
    @IBAction func thursButtonPressed(_ sender: Any) {
        if (checkThur.alpha == 1){
            checkThur.alpha = 0
        }
        else {
            checkThur.alpha = 1
        }
        view.endEditing(true)
    }
    @IBAction func friButtonPressed(_ sender: Any) {
        if (checkFri.alpha == 1){
            checkFri.alpha = 0
        }
        else {
            checkFri.alpha = 1
        }
        view.endEditing(true)
    }
    @IBAction func satButtonPressed(_ sender: Any) {
        if (checkSat.alpha == 1){
            checkSat.alpha = 0
        }
        else {
            checkSat.alpha = 1
        }
        view.endEditing(true)
    }
    @IBAction func sunButtonPressed(_ sender: Any) {
        if (checkSun.alpha == 1){
            checkSun.alpha = 0
        }
        else {
            checkSun.alpha = 1
        }
        view.endEditing(true)
    }
    @IBAction func addMedTapped(_ sender: Any) {
        //send data
        view.endEditing(true)
    }
    @IBAction func cancelMedTapped(_ sender: Any) {
        //go back to med screen
        view.endEditing(true)
    }
    @IBOutlet weak var dosageLabel: UILabel!
    @IBAction func dosageStepper(_ sender: UIStepper) {
        dosageLabel.text = String(Int(sender.value))
        view.endEditing(true)
    }
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBAction func quantityStepper(_ sender: UIStepper) {
        quantityLabel.text = String(Int(sender.value))
        view.endEditing(true)
    }

}

extension MedicationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
/*
extension UIToolbar {
    
    func ToolbarPicker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}
*/
