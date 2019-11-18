/*
File: [CardCollectionViewCell.swift]
Creators: [Jordan]
Date created: [11/14/2019]
Date updated: [11/15/2019]
Updater name: [Jordan]
File description: [Controls the UI behavior of the collectionViewCells for the cards. Used for flipping animations]
*/

import UIKit
import Foundation

class CardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
    
    var card:Card?
    
    //Input: Selected Card object
    //Output: Manages the flipping of the selected card
    //Card disappears if matched
    func setCard(_ card:Card) -> Bool{
        
        //keeps tracks of the card that gets passed in
        self.card = card
        
        if card.isMatched == true{
            
            //if card has been matched then make the image views invisible
            backImageView.alpha = 0
            frontImageView.alpha = 0
            
            return true
        }
        else
        {
            //if the card hasnt been matched then make the image views visible
            backImageView.alpha = 1
            frontImageView.alpha = 1
        }
        
        frontImageView.image = UIImage(named: card.imageName)
        
        //determine if the card is in a flipped up state or flipped down state
        if card.isFlipped == true {
            //make sure frontimageview is on top
            UIView.transition(from: backImageView, to: frontImageView, duration: 0, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
        }
        else
        {
            //make sure the backImageview is on top
            UIView.transition(from: frontImageView, to: backImageView, duration: 0, options: [.showHideTransitionViews, .transitionFlipFromLeft], completion: nil)
        }
        
        return false
        
        
    }
    
    //Input: None
    //Output: Flips from back image view to front image view
    func flip() {
        
        UIView.transition(from: backImageView, to: frontImageView, duration: 0.3, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
    }
    
    //Input: none
    //Output: Flips from backImageView to frontImageView
    func flipBack() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            
            UIView.transition(from: self.frontImageView, to: self.backImageView, duration: 0.3, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        }
        
        
    }
    
    
    //input: none
    //Output: removes both imageViews with fade out animation
    func remove() {
        
        //removes both image views from being visible
        backImageView.alpha = 0

        
        //animate it
        UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseOut, animations: {
            self.frontImageView.alpha = 0

        }, completion: nil)
    }
}

