/*
 File: [MedicationHomeViewController.swift]
 Creators: [Allan, Jordan]
 Date created: [03/11/2019]
 Date updated: [10/11/2019]
 Updater name: [Allan, Jordan]
 File description: [Controls the MyMeds screen in UnHindr]
 */

import UIKit
import FirebaseFirestore

class MedicationHomeViewController: UIViewController {
    // Card index
    var cardIndex: Int = 0
    
    // UIView for medication plan card view
    var card: UIView?
    
    // Index of used cards for today
    var usedCards = [Int]()
    
    // Define the initial view location
    var medViewCenter: CGPoint?
    
    // Snapshot to medication plan for the current day
    var planSnapshot: QuerySnapshot?
    
    // Outlets
    @IBOutlet weak var medicationQty: UILabel!
    @IBOutlet weak var medicationDosage: UILabel!
    @IBOutlet weak var medicationName: UILabel!
    @IBOutlet weak var reminderTime: UILabel!
    @IBOutlet weak var MedCardView: UIView!
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Define the center of the card view
        medViewCenter = MedCardView!.center
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Retrieve snapshot of med plans for current date
        self.getDBMedicationPlan { (querySnapshot) in
            self.planSnapshot = querySnapshot!
            if (!self.fetchAndUpdateCard()) {
                self.card!.alpha = 0
            }
        }
        // Retrieve all meds taken for the current date
        self.getDBPlanTaken { (medTaken, timestamp) in
            print(Date.isToday(timestamp))
            if (Date.isToday(timestamp)){
                self.usedCards = medTaken
                print(self.usedCards)
            }
            else {
                self.usedCards = []
                // Reset timestamp and usedcards on firestore
                Services.userProfileRef.updateData([
                    "MedPlanTimestamp": Timestamp(date: Date()),
                    "MedPlan": []
                    ])
            }
            
        }
        
        
    }
    
    // MARK: - Transitions storyboard to Home Menu
    // Input:
    //      Home button tapped
    // Output:
    //      Switch from Medication to Home menu
    @IBAction func goToHomeTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "HomeScreen", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as UIViewController
        present(vc, animated: true, completion: nil)
    }
    
    // Pan gesture handler for panning medication cards
    // Input:
    //      1. user pan gestures
    // Output:
    //      1. Cycle through the valid medication plans
    @IBAction func PanMedCard(_ sender: UIPanGestureRecognizer) {
        // If there is at least 1 card
        if ( self.planSnapshot!.count != 0) {
            self.card = sender.view!
            let point = sender.translation(in: view)
            self.card!.center = CGPoint(x: self.medViewCenter!.x + point.x, y: self.medViewCenter!.y)
            
            //Check for state to see if user has let go of the screen
            if sender.state == UIGestureRecognizer.State.ended {
                // Check for velocity to switch
                let velocity = sender.velocity(in: view)
                if (Double(abs(velocity.x)) > Constants.medicationVelocityThreshold) {
                    self.switchToNextCard(self.card!, sender)
                }
                else{
                    UIView.animate(withDuration: 1) {
                        self.card!.center = self.medViewCenter!
                    }
                }
                
            }
        }
        
    }
    
    // Get a snapshot of the current medication plan
    // Input:
    //      None
    // Output:
    //      1. querysnapshot of medication plan
    private func getDBMedicationPlan(completionHandler: @escaping (_ result: QuerySnapshot?) -> Void){
        Services.medicationPlanRef
            .whereField("Day", arrayContains: Date.getDayOfWeek(Timestamp.init()).rawValue)
            .order(by: "ReminderTime")
            .getDocuments { (querySnapshot, err) in
            // the program will go into this if statement if the user authentication fails
            if err != nil {
                print("Error getting medication data")
            }
            else {
                //
                completionHandler(querySnapshot!)
            }
        }
    }
    
    // Get a snapshot of the taken medicine for a given timestamp
    // Input:
    //      None
    // Output:
    //      1. array of taken meds and timestamp
    private func getDBPlanTaken(completionHandler: @escaping (_ result: [Int], Timestamp) -> Void){
        Services.userProfileRef.getDocument { (documentSnapshot, error) in
            if error != nil {
                // Error
            }
            else {
                guard let document = documentSnapshot else {
                    // Error fetching user document
                    return
                }
                let medPlanArr = document.get("MedPlan") as! [Int]
                let timestamp = document.get("MedPlanTimestamp") as! Timestamp
                completionHandler(medPlanArr, timestamp)
            }
        }
    }
    
    // Input:
    //      1. None
    // Output:
    //      1. Switch to next available card
    private func switchToNextCard(_ card: UIView,_ sender: UIPanGestureRecognizer) {
        //Check if there are any medication plans for today
        // update card if card index changes
        if (self.indexToNextUnusedCard()) {
            // Update card
            assert(self.fetchAndUpdateCard())
            
            //Animate the popping in
            card.alpha = 0
            //Move the card back to the center
            card.center = self.medViewCenter!
            UIView.animate(withDuration: 1) {
                card.alpha = 1
            }
        }
        
    }
    
    // Input:
    //      1. Global planSnapshot is defined
    // Output:
    //      1. True -> card is successfully updated
    //      2. False -> There is no cards left or plan is not loaded properly
    private func fetchAndUpdateCard() -> Bool{
        // No cards
        if (planSnapshot?.count == 0 || planSnapshot?.count == nil) {
            return false
        }

        // Set the card values to the next card value
        medicationName.text = planSnapshot?.documents[cardIndex].get("Medication") as? String
        // Parse medication time into 12H format
        let timeString = planSnapshot?.documents[cardIndex].get("ReminderTime") as? String
        var arr = timeString!.components(separatedBy: [":"])
        var amPmVar = "AM"
        // if no medication time
        if (arr[0] == "") {
            reminderTime.text = "None"
        }
        else {
            if Int(arr[0])! > 12 {
                arr[0] = String(Int(arr[0])! - 12)
                amPmVar = "PM"
            }
            reminderTime.text = arr[0] + ":" + arr[1] + amPmVar
        }
        // Set the dosage value
        let nextDosage = planSnapshot?.documents[cardIndex].get("Dosage") as? Int
        medicationDosage.text = "Dosage: \(nextDosage!)"
        // Set the quantity value
        let nextQuantity = planSnapshot?.documents[cardIndex].get("Quantity") as? Int
        medicationQty.text = "Qty: \(nextQuantity!)"
        return true
    }
    
    private func indexToNextUnusedCard() -> Bool {
        let queryLength = planSnapshot?.count
        if (queryLength == nil || queryLength == 1) {
            // Return the card to center
            UIView.animate(withDuration: 1) {
                self.card!.center = self.medViewCenter!
            }
            return false
        }
        
        // cycle through cards if med is already taken
        repeat {
            // Check if we are at the end of the medication plan list
            if (cardIndex >= queryLength!-1) {
                cardIndex = 0
            }
            else{
                print("Adding to card index")
                cardIndex += 1
            }
        }while(self.usedCards.contains(cardIndex) && self.usedCards.count < queryLength!)
        
        print("Querylength: \(queryLength!)")
        print("New card index: \(cardIndex)")
        
        return true
    }
    
    // TODO:
    @IBAction func checkmarkTapped(_ sender: UIButton) {
        // Add new document to medication history
        Services.medicationHistoryRef.addDocument(data:[
            "Date": Timestamp(date: Date()),
            "Dosage": planSnapshot!.documents[cardIndex].get("Dosage") as? Int,
            "Medication": planSnapshot!.documents[cardIndex].get("Medication") as? String,
            "Quantity": planSnapshot!.documents[cardIndex].get("Quantity") as? Int
            ])
        // Add card to read list
        self.usedCards.append(cardIndex)
        
        print("New used cards list: \(self.usedCards)")
        
        // Add to MedPlan array and update timestamp
        Services.userProfileRef.updateData([
            "MedPlanTimestamp": Timestamp(date: Date()),
            "MedPlan": self.usedCards
            ])
        
        // Update view
        self.MedCardView.alpha = 0
//        self.card!.alpha = 0
        // Update fields on card with next card view
        if (self.indexToNextUnusedCard()) {
            assert(self.fetchAndUpdateCard())
            //Move the card back to the center
            self.card!.center = self.medViewCenter!
            UIView.animate(withDuration: 1) {
                self.MedCardView.alpha = 1
            }
        }
    }

}
