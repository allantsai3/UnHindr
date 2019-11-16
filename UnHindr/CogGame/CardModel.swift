//
//  CardModel.swift
//  UnHindr
//
//  Created by Jordan Kam on 11/12/19.
//  Copyright © 2019 Sigma. All rights reserved.
//

import Foundation

class CardModel {
    
    //declare and array to store the generated cards
    //randomize array
    //return array
    func getCards() -> [Card] {
    
        //declare array to store numbers we've already generated
        var generatedNumbersArray = [Int]()
        
        //declare an array to store the generated cards
       
        var generatedCardsArray = [Card]()
        
        //randomly generate pairs of cards
        while generatedNumbersArray.count < 9 {
            
            //get a random number
           let randomNumber = arc4random_uniform(13) + 1
            
            //ensure random number is unique
            if generatedNumbersArray.contains(Int(randomNumber)) == false {
                
                //log the number
                print(randomNumber)
                
                //store the number into the generatedNumbersArray
                generatedNumbersArray.append(Int(randomNumber))
                
                //create the first card object
                let cardOne = Card()
                cardOne.imageName = "card\(randomNumber)"
                
                generatedCardsArray.append(cardOne)
                
                //create the second card object
                let cardTwo = Card()
                cardTwo.imageName = "card\(randomNumber)"
                
                generatedCardsArray.append(cardTwo)
            }
            
            
            
            //optional: to generate unique card number
        }
        
        //to do: randomize array
        
        //return the array
        return generatedCardsArray.shuffled()
        
    }
}
