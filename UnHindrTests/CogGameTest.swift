/*
 File: [CogGameTests.swift]
 Creators: [Jordan Kam]
 Date created: [11/17/2019]
 Date updated: [11/17/2019]
 Updater name: [Jordan Kam]
 File description: [Unit testing of the functions and methods contained in the Cognitive Game Module]
 */

import XCTest
@testable import UnHindr
import FirebaseAuth
import Firebase


class CogGameTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    

    //Input: None
    //Output: Tests that the Card array used for the game is populated and not empty
    func testCardGenerationPopulated() {
        
        let model = CardModel()
        var cardArray = [Card]()
        
        cardArray = model.getCards()
        
        if cardArray.count <= 0 {
            XCTFail("Generated card array is empty")
        }
    }
    
    
    //Input: None
    //Output: Tests that the images are properly assigned to each card object generated
    func testCardImageGenerated() {
        let model = CardModel()
        var cardArray = [Card]()
        var card:Card!
        card = Card()
        
        cardArray = [Card]()
        cardArray = model.getCards()
        for card in cardArray{
    
            if card.imageName == "" {
                XCTFail("Image not assigned to card")
            }
        }
        
    }
    
    //Input: None
    //Output: Tests that the soundManager properly checks the validity of soundFile
    func testSoundManager() {
        let soundFilename = "cardflip"
        
        let bundlePath = Bundle.main.path(forResource: soundFilename, ofType: "wav")
        
        guard bundlePath != nil
        else {
            XCTFail("Couldnt find sound file in the bundle")
            return
        }
    }

}
