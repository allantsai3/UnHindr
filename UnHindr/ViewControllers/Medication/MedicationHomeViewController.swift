/*
 File: [MedicationHomeViewController.swift]
 Creators: [Allan, Jordan]
 Date created: [03/11/2019]
 Date updated: [17/11/2019]
 Updater name: [Allan, Jordan]
 File description: [Controls the MyMeds screen in UnHindr]
 */

import UIKit
import FirebaseFirestore

class MedicationHomeViewController: UIViewController, NewMedDelegate {
    // Card index
    var cardIndex: Int = 0
    
    // Index of used cards for today
    var usedCards = [Int]()
    
    // Define the initial view location
    var medViewCenter: CGPoint?
    
    // Snapshot to medication plan for the current day
    var planSnapshot: QuerySnapshot? = nil
    
    // Outlets
    @IBOutlet weak var medicationQty: UILabel!
    @IBOutlet weak var medicationDosage: UILabel!
    @IBOutlet weak var medicationName: UILabel!
    @IBOutlet weak var reminderTime: UILabel!
    
    // Card view for panning
    @IBOutlet weak var MedCardView: UIView!
    
    // MARK: - View controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Define the center of the card view
        medViewCenter = MedCardView!.center
        
        
        // Retrieve all meds taken for the current date (fetches a remote copy for data persistence on reboot)
        // Must be done before getDBMedicationPlan to retrieve the self.usedCards data
        self.getDBPlanTaken { (medTaken, timestamp) in
            print(Date.isToday(timestamp))
            // Need to update the indices if new meds are added for the current day
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
        // Retrieve snapshot of med plans for current date
        self.getDBMedicationPlan { (querySnapshot) in
            self.planSnapshot = querySnapshot!
            self.switchToNextCard(self.MedCardView)
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            self.MedCardView = sender.view!
            let point = sender.translation(in: view)
            self.MedCardView!.center = CGPoint(x: self.medViewCenter!.x + point.x, y: self.medViewCenter!.y)
            
            //Check for state to see if user has let go of the screen
            if sender.state == UIGestureRecognizer.State.ended {
                // Check for velocity to switch
                let velocity = sender.velocity(in: view)
                if (Double(abs(velocity.x)) > Constants.medicationVelocityThreshold) {
                    self.switchToNextCard(self.MedCardView!)
                }
                else{
                    UIView.animate(withDuration: 1) {
                        self.MedCardView!.center = self.medViewCenter!
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
    
    // MARK: - Medication Card functions
    // Precondition:
    //          1. Needs to be public function
    // Input:
    //          1. Data passed from MedicationViewController using protocols
    // Output:
    //          1. Sorts the usedCards array
    func onMedAdded(documentID: String) {
        print("Data received: \(documentID)")
        // Update the remote array
        var count: Int = 0
        self.getDBMedicationPlan { (querySnapshot) in
            for document in querySnapshot!.documents {
                if document.documentID == documentID {
                    break
                }
                count += 1
            }
            
            // Modify the usedCard array based on the index location
            for i in 0..<(self.usedCards.count) {
                if (self.usedCards[i] >= count) {
                    self.usedCards[i] += 1
                }
            }
            
            // Store new array to DB
            self.updateMedPlanTakenArray()
        }
        
    }
    
    // Function that attempts to switch to next card
    // Preconditions:
    //      1. self.usedCards is updated with the current remote value
    // Input:
    //      1. None
    // Output:
    //      1. Switch to next available card
    private func switchToNextCard(_ card: UIView) {
        //Check if there are any medication plans for today
        // Update view
        self.MedCardView.alpha = 0
        
        // Update fields on card with next card view
        if (self.indexToNextUnusedCard()) {
            assert(self.fetchAndUpdateCard())
            //Move the card back to the center
            self.MedCardView!.center = self.medViewCenter!
            UIView.animate(withDuration: 1) {
                self.MedCardView.alpha = 1
            }
        }
        
    }
    
    // Function that updates the med card given the condition that a card is available
    // Preconditions:
    //      1. Global planSnapshot is defined
    //      2. Card index is updated with the new medication
    //      3. A medication is defined and untaken for the current day
    // Inputs:
    //      None
    // Output:
    //      1. True -> card is successfully updated with
    //      2. False -> There is no cards left or plan is not loaded properly
    private func fetchAndUpdateCard() -> Bool{
        // No cards
        if (planSnapshot!.count == 0) {
            return false
        }

        // Set the card values to the next card value
        medicationName.text = planSnapshot!.documents[cardIndex].get("Medication") as? String
        // Parse medication time into 12H format
        let timeString = planSnapshot!.documents[cardIndex].get("ReminderTime") as? String
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
    
    // Helper function that attempts to index to the next unused card if available for the current day
    // Input:
    //      1. planSnapshot must be defined
    // Output:
    //      1. True -> 1 or more medication has not been taken for the current day (cycles the index to the next available medication)
    //      2. False -> No medication plan for the current day or all meds are taken for the current day ( Resets the card to the center of the screen)
    private func indexToNextUnusedCard() -> Bool {
        let queryLength = planSnapshot!.count
        // If there is no medication plan or only 1 plan for the current day
        if (queryLength == 1 || self.usedCards.count == queryLength) {
            // Return the card to center
            UIView.animate(withDuration: 1) {
                self.MedCardView!.center = self.medViewCenter!
            }
            return false
        }
        
        // cycle through cards if med is already taken
        repeat {
            // Check if we are at the end of the medication plan list
            if (cardIndex >= queryLength-1) {
                cardIndex = 0
            }
            else{
                print("Adding to card index")
                cardIndex += 1
            }
        }while(self.usedCards.contains(cardIndex) && self.usedCards.count < queryLength)
        
        print(self.usedCards)
        print("Querylength: \(queryLength)")
        print("New card index: \(cardIndex)")
        
        return true
    }
    
    // MARK: - Action that acknowledges the status of the current med card as taken
    // Input:
    //      1. Must have 1 or more cards for the current day (self.usedCard.count < planSnapshot?.count)
    // Output:
    //      1. Adds the current card to the usedCard list and and attempts to fetch the next card
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
        
        self.updateMedPlanTakenArray()
        
        self.switchToNextCard(self.MedCardView)
    }
    
    private func updateMedPlanTakenArray() {
        // Add to MedPlan array and update timestamp
        Services.userProfileRef.updateData([
            "MedPlanTimestamp": Timestamp(date: Date()),
            "MedPlan": self.usedCards
            ])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addMedSegue" {
            let addMedVC: MedicationViewController = segue.destination as! MedicationViewController
            addMedVC.delegate = self
        }
    }

}
