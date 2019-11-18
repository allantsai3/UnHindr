/*
File: [CogGameViewController.swift]
Creators: [Jordan]
Date created: [11/14/2019]
Date updated: [11/15/2019]
Updater name: [Jordan]
File description: [Controls the CogGame screen UI view. Controls way cards are displayed on scren, along with game logic, timer settings, and user interaction protocols]
*/

import Foundation
import UIKit
import Firebase
import FirebaseAuth



class CogGameViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var model = CardModel()
    var cardArray = [Card]()
    
    //initiaize a timer object
    var timer : Timer?
    
    //The number of seconds the player has to complete the matching game
    var seconds = 120
    
    //number of matches the player has made
    var matches = 0
    
    
    
    
    var firstFlippedCardIndex:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //call getCards method of the card model
        cardArray = model.getCards()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //create timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerElapsed), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        
        scoreElapsed()
        
    }

    //Input: None (When view appears)
    //Output: Plays a shuffle sound
    override func viewDidAppear(_ animated: Bool) {
        
        SoundManager.playSound(.shuffle)
    }
    
    
    //Input: None
    //Output: Updates the number of cards matched to the screen
    @objc func scoreElapsed() {
        
        scoreLabel.text = "Cards Matched: \(matches)"
        
    }
    
    
    
    
    //MARK: - Timer Methods
    
    //Input: None
    //Output: Updates the timer in seconds, Changes time color to red when reaches 0
    @objc func timerElapsed(){
        
        seconds -= 1
        
        //convert to seconds
        //let seconds = String(format: "", seconds)
        
        //set label
        timerLabel.text = "Time Remaining: \(seconds)"
        
        if seconds <= 0 {
            timer?.invalidate()
            timerLabel.textColor = UIColor.red
            
            //check if there any cards unmatched
            checkGameEnded()
        }
        
        
    }
    
    
    
    
    //MARK: - CollectionViewCell Formatting
   
    //sets the number of items on a row
    //Input: The collection view, view layout, and index path of cell item
    //Output: A struct with width and height parameters.
    //Function sets the number of items on a row based on width and height of view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width/4.0
        let yourHeight = yourWidth
        
        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    //Input: collectionView, CollectionViewlayout, section
    //Output: Configures the spacing for items relative to the view
    //sets spacing for items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    //Input: UICollectionView, ViewLayout, and section number
    //Output: Sets the side by side spacing for items in the CollectionView
    //sets spacing for items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return -10
    }
    
    //Input: CollectionView, ViewLayout, and section number
    //Output: sets spacing for items vertically
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }
    

    
    
    // MARK: - UICollectionView Protocol Methods
    
    //Input: collectionView and section number
    //Output: Asks delegate how many items need to be displayed
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardArray.count
    }
    
    //Input: collectionView, and cell index path
    //Output: collectionView asks datasource (Viewcontroller for new data to display - for each individual cell to be displayed
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //get a cardCollectionViewCell object
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        //get the card that the collection view is trying to display
        let card = cardArray[indexPath.row]
        
        //set the card for that cell
        cell.setCard(card)
        
        return cell
    }
    
    
    //input: User selection on the grid (User taps on a cell in the grid)
    //Output: Flips the card when user clicks on it. Play sounds when user clicks on it. Check for a match when two cards are flipped
    //protocol method is part of UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if seconds <= 0 {
            return
        }
        
        //get cell that user selected
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        
        //get card that user selected
        let card = cardArray[indexPath.row]
        
        if card.isFlipped == false && card.isMatched == false
        {
            //flip the card
            cell.flip()
            
            //play the flip sound
            SoundManager.playSound(.flip)
            
            
            //set status of the card
            card.isFlipped = true
            
            //determine if its the first card or second card thats flipped over
            if firstFlippedCardIndex == nil {
                
                //this is the first card being flipped
                firstFlippedCardIndex = indexPath
                
            }
            else
            {
                //this is the second card being flipped
                
                //performs the matching logic
                checkForMatches(indexPath)
            }
        }
        
    } //end of the didSelectItemAt method
    
    
    
    
    //MARK: - Game Logic Methods
    
    
    //Input: indexPath of the second card flipped
    //Output: compares the first and second card's images to see if they are a match
    //plays a sound if it is a match
    //Updates amount of matched cards
    //Checks if game has ended
    //Flips the cards back down if they are not a match with sound effect
    func checkForMatches(_ secondFlippedCardIndex:IndexPath){
        
        
        //get the cells for the two cards that were revealed
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCollectionViewCell
        
        let cardTwoCell = collectionView.cellForItem(at: secondFlippedCardIndex) as? CardCollectionViewCell
        
        //get the cards for the two cards that were revealed
        let cardOne = cardArray[firstFlippedCardIndex!.row]
        let cardTwo = cardArray[secondFlippedCardIndex.row]
        
        //compare the two cards
        if cardOne.imageName == cardTwo.imageName {
            
            //its a match
            
            //Play sound
            SoundManager.playSound(.match)
            
            //set status of the cards
            cardOne.isMatched = true
            cardTwo.isMatched = true
            
            matches += 1
            scoreElapsed()
            
            //remove the cards from the grid
            cardOneCell?.remove()
            cardTwoCell?.remove()
            
            
            //check if there any cards left unmatched
            checkGameEnded()
        }
        else
        {
            
            //its not a match
            
            //play sound
            SoundManager.playSound(.nomatch)
            
            //set the statuses of the cards
            cardOne.isFlipped = false
            cardTwo.isFlipped = false
            
            //flip both cards back
            cardOneCell?.flipBack()
            cardTwoCell?.flipBack()
            
            
        }
        
        //tell the collectionView to reload the cell of the first card if it is nil
        if cardOneCell == nil {
            collectionView.reloadItems(at: [firstFlippedCardIndex!])
        }
        
        
        //reset the property that tracks the first card flipped
        firstFlippedCardIndex = nil
    }
    
    
    //Input: None
    //Output: Checks every card in the game to see if they are all matched together
    //Final score is calculated based on cards matched + time remaining
    //If all cards are matched then display winning alert to screen
    //If cards are not all matched then losing alert is displayed
    //Sends the score and date to the firebase database
    func checkGameEnded() {
        
        //determine if there any cards left unmatched
        var isWon = true
        var timeRemaining = 0
        var score = 0
        
        //check that every card in the array is matched, if so, then game is won
        for card in cardArray {
            
            if card.isMatched == false {
                
                isWon = false
                break
            }
            
        }
        
        
        //Initialize messaging variables
        var title = ""
        var message = ""
        
        //if not, then user has won, stop timer
        if isWon == true {
            
            timeRemaining = seconds
            score = timeRemaining + matches
            
            
            if seconds > 0 {
                timer?.invalidate()
                
            }
            
            title = "Congratulations!"
            message = "You Won!\n\nYou Matched: \(matches) Cards\nTime Remaining: \(timeRemaining) Seconds\n\nYour Score is:\n\(matches) (Matched Cards) + \(timeRemaining) (Time Bonus) = \(score)"
            
            var ref: DocumentReference? = nil
            ref = Services.db.collection("users").document(Services.userRef!).collection("CogGameData").addDocument(data: [
                "Date": Timestamp(date: Date()),
                "Score": score
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            
        }
        else {
            //if there are unmatched cards check if there are any cards left

            timeRemaining = seconds
            score = timeRemaining + matches
            
            if seconds > 0 {
                return
            }
            
            title = "Game Over"
            message = "You've Lost\n\nYou Matched: \(matches) Cards\nTime Remaining: \(timeRemaining) Seconds\n\nYour Score is:\n\(matches) (Matched Cards) + \(timeRemaining) (Time Bonus) = \(score)"
            
            var ref: DocumentReference? = nil
            ref = Services.db.collection("users").document(Services.userRef!).collection("CogGameData").addDocument(data: [
                "Date": Timestamp(date: Date()),
                "Score": score
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            
        }
        
        //show won or lost message
        showAlert(title, message)
        
    }
    
    //Input: Takes in a title and message string parameter
    //Output: Configures how the alert will be displayed to screen
    func showAlert(_ title:String, _ message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    

    
} //end of viewController class
