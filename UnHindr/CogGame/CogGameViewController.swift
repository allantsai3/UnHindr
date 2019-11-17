//
//  CogGameViewController.swift
//  UnHindr
//
//  Created by Jordan Kam on 11/12/19.
//  Copyright © 2019 Sigma. All rights reserved.
//

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
    
    var timer : Timer?
    var seconds = 120
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        SoundManager.playSound(.shuffle)
    }
    
    @objc func scoreElapsed() {
        
        scoreLabel.text = "Cards Matched: \(matches)"
        
    }
    
    
    
    
    //MARK: Timer Methods
    
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width/4.0
        let yourHeight = yourWidth
        
        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    //sets spacing for items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    //sets spacing for items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return -10
    }
    
    //sets spacing for items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }
    

    
    
    // MARK: - UICollectionView Protocol Methods
    
    //ask delegate how many items need to be displayed
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardArray.count
    }
    
    //collectionView asks dataSource (viewController) for new data to display - for each individual cell to be displayed
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //get a cardCollectionViewCell object
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        //get the card that the collection view is trying to display
        let card = cardArray[indexPath.row]
        
        //set the card for that cell
        cell.setCard(card)
        
        return cell
    }
    
    //when a user taps on a cell in the grid
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
    
    func checkGameEnded() {
        
        //determine if there any cards left unmatched
        var isWon = true
        var numMatches = 0
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
    
    //Configures how the alert will be displayed to screen
    //Takes in a title and message parameter and displays alert to screen
    func showAlert(_ title:String, _ message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    

    
} //end of viewController class
