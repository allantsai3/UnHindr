/*
 File: [CogGameUITests.swift]
 Creators: [Jordan]
 Date created: [11/17/2019]
 Date updated: [11/17/2019]
 Updater name: [Jordan]
 File description: [Tests the UI for the cognitive game]
 */

import XCTest
@testable import UnHindr

class CogGameUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    //MARK: - Test navigation to the Cognitive Game
    //Input: none
    //Output: Navigates from the login screen to the HomeScreen and then the Cognitive game
    func testNavToGame() {
        let app = XCUIApplication()
        loginToHomeScreen(app)
        
        XCTAssert(app.buttons["Wellness"].waitForExistence(timeout: 5))
        app.buttons["Wellness"].tap()
        
        XCTAssert(app.buttons["CogGameButton"].waitForExistence(timeout: 5))
        app.buttons["CogGameButton"].tap()
        
    }
    
    
    //MARK: - Tests loading in of cards to view
    //Input: None
    //Output: Ensures the cards exists in the UIView
    func testCards() {
        let app = XCUIApplication()
        loginToHomeScreen(app)
        
        
        XCTAssert(app.buttons["Wellness"].waitForExistence(timeout: 5))
        app.buttons["Wellness"].tap()
        
        XCTAssert(app.buttons["CogGameButton"].waitForExistence(timeout: 5))
        app.buttons["CogGameButton"].tap()
        
        
        let collectionViewsQuery = app.collectionViews
        let back1Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 0).otherElements.containing(.image, identifier:"back-1").element

        let back2Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 1).otherElements.containing(.image, identifier:"back-1").element
        
        let back3Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 2).otherElements.containing(.image, identifier:"back-1").element
        
        let back4Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 3).otherElements.containing(.image, identifier:"back-1").element
        
        let back5Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 4).otherElements.containing(.image, identifier:"back-1").element
        
        let back6Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 5).otherElements.containing(.image, identifier:"back-1").element
        
        let back7Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 6).otherElements.containing(.image, identifier:"back-1").element
        
        let back8Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 7).otherElements.containing(.image, identifier:"back-1").element
        
        let back9Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 8).otherElements.containing(.image, identifier:"back-1").element
        
        let back10Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 9).otherElements.containing(.image, identifier:"back-1").element
        
        let back11Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 10).otherElements.containing(.image, identifier:"back-1").element
        
        let back12Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 11).otherElements.containing(.image, identifier:"back-1").element
        
        let back13Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 12).otherElements.containing(.image, identifier:"back-1").element
        
        let back14Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 13).otherElements.containing(.image, identifier:"back-1").element
        
        let back15Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 14).otherElements.containing(.image, identifier:"back-1").element
        
        let back16Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 15).otherElements.containing(.image, identifier:"back-1").element
        
        let back17Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 16).otherElements.containing(.image, identifier:"back-1").element
        
        let back18Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 17).otherElements.containing(.image, identifier:"back-1").element


    
     
        //test all cards elements
        XCTAssert(back1Element.exists)
        XCTAssert(back2Element.exists)
        XCTAssert(back3Element.exists)
        XCTAssert(back4Element.exists)
        XCTAssert(back5Element.exists)
        XCTAssert(back6Element.exists)
        XCTAssert(back7Element.exists)
        XCTAssert(back8Element.exists)
        XCTAssert(back9Element.exists)
        XCTAssert(back10Element.exists)
        XCTAssert(back11Element.exists)
        XCTAssert(back12Element.exists)
        XCTAssert(back13Element.exists)
        XCTAssert(back14Element.exists)
        XCTAssert(back15Element.exists)
        XCTAssert(back16Element.exists)
        XCTAssert(back17Element.exists)
        XCTAssert(back18Element.exists)

    
        

    }
    
    //MARK: - Test Card Flipping
    //Input: None
    //Output: Tests the flipping user interactibility of each card on the UIView
    func testCardFlip(){
        let app = XCUIApplication()
        loginToHomeScreen(app)
        
        
        XCTAssert(app.buttons["Wellness"].waitForExistence(timeout: 5))
        app.buttons["Wellness"].tap()
        
        XCTAssert(app.buttons["CogGameButton"].waitForExistence(timeout: 5))
        app.buttons["CogGameButton"].tap()
        
        
        let collectionViewsQuery = app.collectionViews
        let back1Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 0).otherElements.containing(.image, identifier:"back-1").element
        
        let back2Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 1).otherElements.containing(.image, identifier:"back-1").element
        
        let back3Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 2).otherElements.containing(.image, identifier:"back-1").element
        
        let back4Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 3).otherElements.containing(.image, identifier:"back-1").element
        
        let back5Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 4).otherElements.containing(.image, identifier:"back-1").element
        
        let back6Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 5).otherElements.containing(.image, identifier:"back-1").element
        
        let back7Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 6).otherElements.containing(.image, identifier:"back-1").element
        
        let back8Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 7).otherElements.containing(.image, identifier:"back-1").element
        
        let back9Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 8).otherElements.containing(.image, identifier:"back-1").element
        
        let back10Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 9).otherElements.containing(.image, identifier:"back-1").element
        
        let back11Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 10).otherElements.containing(.image, identifier:"back-1").element
        
        let back12Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 11).otherElements.containing(.image, identifier:"back-1").element
        
        let back13Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 12).otherElements.containing(.image, identifier:"back-1").element
        
        let back14Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 13).otherElements.containing(.image, identifier:"back-1").element
        
        let back15Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 14).otherElements.containing(.image, identifier:"back-1").element
        
        let back16Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 15).otherElements.containing(.image, identifier:"back-1").element
        
        let back17Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 16).otherElements.containing(.image, identifier:"back-1").element

        let back18Element = collectionViewsQuery.children(matching: .cell).element(boundBy: 17).otherElements.containing(.image, identifier:"back-1").element

        
        var elementArray: [XCUIElement] = []
        
        elementArray.append(back1Element)
        elementArray.append(back2Element)
        elementArray.append(back3Element)
        elementArray.append(back4Element)
        elementArray.append(back5Element)
        elementArray.append(back6Element)
        elementArray.append(back7Element)
        elementArray.append(back8Element)
        elementArray.append(back9Element)
        elementArray.append(back10Element)
        elementArray.append(back11Element)
        elementArray.append(back12Element)
        elementArray.append(back13Element)
        elementArray.append(back14Element)
        elementArray.append(back15Element)
        elementArray.append(back16Element)
        elementArray.append(back17Element)
        elementArray.append(back18Element)

        
        
        //Check Card 1 matches
        XCTAssert(elementArray[0].waitForExistence(timeout: 5))
        elementArray[0].tap()
        
        XCTAssert(elementArray[1].waitForExistence(timeout: 5))
        elementArray[1].tap()
    
        XCTAssert(elementArray[2].waitForExistence(timeout: 5))
        elementArray[2].tap()
        
        XCTAssert(elementArray[3].waitForExistence(timeout: 5))
        elementArray[3].tap()
        
        XCTAssert(elementArray[4].waitForExistence(timeout: 5))
        elementArray[4].tap()
        
        XCTAssert(elementArray[5].waitForExistence(timeout: 5))
        elementArray[5].tap()
        
        XCTAssert(elementArray[6].waitForExistence(timeout: 5))
        elementArray[6].tap()
        
        XCTAssert(elementArray[7].waitForExistence(timeout: 5))
        elementArray[7].tap()
        
        XCTAssert(elementArray[8].waitForExistence(timeout: 5))
        elementArray[8].tap()
        
        XCTAssert(elementArray[9].waitForExistence(timeout: 5))
        elementArray[9].tap()
        
        XCTAssert(elementArray[10].waitForExistence(timeout: 5))
        elementArray[10].tap()
        
        XCTAssert(elementArray[11].waitForExistence(timeout: 5))
        elementArray[11].tap()
        
        XCTAssert(elementArray[12].waitForExistence(timeout: 5))
        elementArray[12].tap()
        
        XCTAssert(elementArray[13].waitForExistence(timeout: 5))
        elementArray[13].tap()
        
        XCTAssert(elementArray[14].waitForExistence(timeout: 5))
        elementArray[14].tap()
        
        XCTAssert(elementArray[15].waitForExistence(timeout: 5))
        elementArray[15].tap()
        
        XCTAssert(elementArray[16].waitForExistence(timeout: 5))
        elementArray[16].tap()
        
        XCTAssert(elementArray[17].waitForExistence(timeout: 5))
        elementArray[17].tap()
     


    }
    

    
    
    func loginToHomeScreen(_ app: XCUIApplication){
        // Login to the home screen
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("unittestacc@gmail.com\n")
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("testtest\n")
        app.buttons["Login Button"].tap()
        //Wait
        XCTAssert(app.buttons["Options"].waitForExistence(timeout: 5))
    }

}
