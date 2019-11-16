/*
 File: [MedicationViewController.swift]
 Creators: [Jake, Sina]
 Date created: [29/10/2019]
 Date updated: [10/11/2019]
 Updater name: [Sina, Allan]
 File description: [Controls the Add New Med screen]
 */

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase


class MedicationViewController: UIViewController {
//    @IBOutlet weak var checkMon: UIImageView!
//    @IBOutlet weak var checkTues: UIImageView!
//    @IBOutlet weak var checkWed: UIImageView!
//    @IBOutlet weak var checkThur: UIImageView!
//    @IBOutlet weak var checkFri: UIImageView!
//    @IBOutlet weak var checkSat: UIImageView!
//    @IBOutlet weak var checkSun: UIImageView!
    
    @IBOutlet weak var monButton: UIButton!
    @IBOutlet weak var tuesButton: UIButton!
    @IBOutlet weak var wedButton: UIButton!
    @IBOutlet weak var thursButton: UIButton!
    @IBOutlet weak var friButton: UIButton!
    @IBOutlet weak var satButton: UIButton!
    @IBOutlet weak var sunButton: UIButton!
    @IBOutlet weak var medFieldName: UITextField!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var dosageLabel: UILabel!
    @IBOutlet weak var timeInputTextField: UITextField!
    
    
    // Store user object from authentication
    private var user: User?
    private var dayOFWeek: [String:Int] = ["Sunday":0, "Saturday":0, "Friday":0, "Thursday":0, "Wednesday":0, "Tuesday":0, "Monday":0]
    private var Dosage = 0
    private var Quantity = 0
    private var MedicationName = ""
    private var ReminderTime = ""
    private var timePicker: UIDatePicker?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configureMedNameText()
        configureTapGesture()
        
        //Configure date picker text field to be a time picker instead
        timePicker = UIDatePicker()
        timePicker?.datePickerMode = .time
        timePicker?.addTarget(self, action: #selector(MedicationViewController.timeChanged(timePicker:)), for: .valueChanged)
        timeInputTextField.inputView = timePicker
        
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
    
    
    // MARK - Stores the medication data to the database
    // Input: None
    // Output:
    //      1. User's medication data is persistently stored in database
    private func storeToDB(){
        //User should be logged in with reference created
        // Add a new document with a generated id.
        let daysArr = initArrayToPassDays()
        self.MedicationName = medFieldName.text!
        print(daysArr)
        var ref: DocumentReference? = nil
        ref = Services.db.collection("users").document(Services.userRef!).collection("MedicationPlan").addDocument(data: [
            "Dosage": self.Dosage,
            "Medication": self.MedicationName,
            "Quantity": self.Quantity,
            "ReminderTime": self.ReminderTime,
            "Day" : daysArr
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    // MARK - Extract the days of week to store for the medication
    // Input: None
    // Output:
    //      1. return an array filled with days of week chosen for medication
    private func initArrayToPassDays()-> Array<String>{
        let temp = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        var retArr = [String]()
        for days in temp {
            if (self.dayOFWeek[days] == 1){
                retArr.append(days)
            }
        }
        return retArr
    }
    
    // MARK - Tapping time picker text field brings up the date picker configured to mode: time
    // Input: Timepicker text field of type UIDatePicker
    // Output:
    //      1. Time selected by user in time slider shown in the timepicker text field
    @objc func timeChanged(timePicker: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        
        let timeString = timeFormatter.string(from: timePicker.date)
        timeInputTextField.text = timeString
        
        // Change the database time storing into 24H format
        var arr = timeString.components(separatedBy: [":", " "])
        if arr[2] == "PM" {
            arr[0] = String(Int(arr[0])! + 12)
        }
        self.ReminderTime = arr[0] + ":" + arr[1]
    }
    
    // MARK - Tapping Mon box toggles checkmark between shown and hidden. Store value in day array
    // Input:
    //      1. Mon button tapped
    // Output:
    //      1. Check is hidden if button is tapped while check is shown, check is shown if button is tapped while hidden, alpha value is stored in day array
    @IBAction func monButtonTapped(_ sender: Any) {
        if (self.dayOFWeek["Monday"] == 1){
            self.dayOFWeek["Monday"] = 0
            monButton.setImage(UIImage(named: "monNoCheck.png"), for: UIControl.State.normal)
        }
        else {
            monButton.setImage(UIImage(named: "MonCheck.png"), for: UIControl.State.normal)
            self.dayOFWeek["Monday"] = 1
        }
        view.endEditing(true)
    }
    
    // MARK - Tapping Mon box toggles checkmark between shown and hidden. Store value in day array
    // Input:
    //      1. Tues button tapped
    // Output:
    //      1. Check is hidden if button is tapped while check is shown, check is shown if button is tapped while hidden, alpha value is stored in day array
    @IBAction func tuesButtonTapped(_ sender: Any) {
        if (self.dayOFWeek["Tuesday"] == 1){
            self.dayOFWeek["Tuesday"] = 0
            tuesButton.setImage(UIImage(named: "tuesNoCheck.png"), for: UIControl.State.normal)
        }
        else {
            self.dayOFWeek["Tuesday"] = 1
            tuesButton.setImage(UIImage(named: "tuesCheck.png"), for: UIControl.State.normal)
        }
        view.endEditing(true)
    }
    
    // MARK - Tapping Mon box toggles checkmark between shown and hidden. Store value in day array
    // Input:
    //      1. Wed button tapped
    // Output:
    //      1. Check is hidden if button is tapped while check is shown, check is shown if button is tapped while hidden, alpha value is stored in day array
    @IBAction func wedButtonTapped(_ sender: Any) {
        if (self.dayOFWeek["Wednesday"] == 1){
            self.dayOFWeek["Wednesday"] = 0
            wedButton.setImage(UIImage(named: "wedNoCheck.png"), for: UIControl.State.normal)
        }
        else {
             self.dayOFWeek["Wednesday"] = 1
             wedButton.setImage(UIImage(named: "wedCheck.png"), for: UIControl.State.normal)
        }
        view.endEditing(true)
    }
    
    // MARK - Tapping Mon box toggles checkmark between shown and hidden. Store value in day array
    // Input:
    //      1. Thurs button tapped
    // Output:
    //      1. Check is hidden if button is tapped while check is shown, check is shown if button is tapped while hidden, alpha value is stored in day array
    @IBAction func thursButtonPressed(_ sender: Any) {
        if (self.dayOFWeek["Thursday"] == 1){
            self.dayOFWeek["Thursday"] = 0
            thursButton.setImage(UIImage(named: "thursNoCheck.png"), for: UIControl.State.normal)
        }
        else {
            self.dayOFWeek["Thursday"] = 1
            thursButton.setImage(UIImage(named: "thursCheck.png"), for: UIControl.State.normal)
        }
        view.endEditing(true)
    }
    
    // MARK - Tapping Mon box toggles checkmark between shown and hidden. Store value in day array
    // Input:
    //      1. Fri button tapped
    // Output:
    //      1. Check is hidden if button is tapped while check is shown, check is shown if button is tapped while hidden, alpha value is stored in day array
    @IBAction func friButtonPressed(_ sender: Any) {
        if (self.dayOFWeek["Friday"] == 1){
            self.dayOFWeek["Friday"] = 0
            friButton.setImage(UIImage(named: "friNoCheck.png"), for: UIControl.State.normal)
        }
        else {
            self.dayOFWeek["Friday"] = 1
            friButton.setImage(UIImage(named: "friCheck.png"), for: UIControl.State.normal)
        }
        view.endEditing(true)
    }
    
    // MARK - Tapping Mon box toggles checkmark between shown and hidden. Store value in day array
    // Input:
    //      1. Sat button tapped
    // Output:
    //      1. Check is hidden if button is tapped while check is shown, check is shown if button is tapped while hidden, alpha value is stored in day array
    @IBAction func satButtonPressed(_ sender: Any) {
        if (self.dayOFWeek["Saturday"] == 1){
            self.dayOFWeek["Saturday"] = 0
            satButton.setImage(UIImage(named: "saturday.png"), for: UIControl.State.normal)
        }
        else {
            self.dayOFWeek["Saturday"] = 1
            satButton.setImage(UIImage(named: "satCheck.png"), for: UIControl.State.normal)

        }
        view.endEditing(true)
    }
    
    // MARK - Tapping Mon box toggles checkmark between shown and hidden. Store value in day array
    // Input:
    //      1. Sun button tapped
    // Output:
    //      1. Check is hidden if button is tapped while check is shown, check is shown if button is tapped while hidden, alpha value is stored in day array
    @IBAction func sunButtonPressed(_ sender: Any) {
        if (self.dayOFWeek["Sunday"] == 1){
            self.dayOFWeek["Sunday"] = 0
            sunButton.setImage(UIImage(named: "sunday.png"), for: UIControl.State.normal)
        }
        else {
            self.dayOFWeek["Sunday"] = 1
            sunButton.setImage(UIImage(named: "sunCheck.png"), for: UIControl.State.normal)
        }
        view.endEditing(true)
    }
    
    // MARK - Adds medication, sends data to firebase
    // Input:
    //      1. Add button tapped
    // Output:
    //      1. Calls storeToDB() in order to save the medication, returns User to MyMeds screen (done in storyboard)
    @IBAction func addMedTapped(_ sender: Any) {
        self.storeToDB()
        view.endEditing(true)
         performSegue(withIdentifier: "ToMedHome", sender: self)
    }
    
    // MARK - Cancels medication, saves no data
    // Input:
    //      1. Cancel button tapped
    // Output:
    //      1. Returns User to MyMeds screen (done in stroyboard)
    @IBAction func cancelMedTapped(_ sender: Any) {
        view.endEditing(true)
         performSegue(withIdentifier: "ToMedHome", sender: self)
    }

    // MARK: - Control the value of the dosage label through a stepper
    // Input:
    //      1. Dosage stepper tapped, stepper incremented or decremented
    // Output:
    //      1. Displays value of stepper in the dosage label
    @IBAction func dosageStepper(_ sender: UIStepper) {
        self.Dosage = Int(sender.value)
        dosageLabel.text = String(self.Dosage)
        view.endEditing(true)
    }
    
    // MARK: - Control the value of the quantity label through a stepper
    // Input:
    //      1. Quantity Stepper
    // Output:
    //      1. Displays value of stepper in the quantity label
    @IBAction func quantityStepper(_ sender: UIStepper) {
        self.Quantity = Int(sender.value)
        quantityLabel.text = String(self.Quantity)
        view.endEditing(true)
    }

    // MARK: - Causes the keyboard to be dismissed
    // Input:
    //      None
    // Output:
    //      Causes the keyboard to be dismissed
    @objc func handleTapOutsideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Allows the text field to use the extension function textFieldShouldReturn()
    // Input:
    //      None
    // Output:
    //      Allows the text field to use the extension function textFieldShouldReturn()
    private func configureMedNameText(){
        medFieldName.delegate = self
    }
    
    // MARK: - Enables a tap outside of the keyboard to call handleTapOutsideKeyboard()
    // Input:
    //      None
    // Output:
    //      Enables a tap outside of the keyboard to call handleTapOutsideKeyboard()
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MedicationViewController.handleTapOutsideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
}

// MARK: - Allows the return button in the keyboard to dismiss the keyboard
// Input:
//      None
// Output:
//      Allows the return button in the keyboard to dismiss the keyboard
extension MedicationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
