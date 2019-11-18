//
//  CogGameUITests.swift
//  UnHindrUITests
//
//  Created by Jordan Kam on 2019-11-17.
//  Copyright © 2019 Sigma. All rights reserved.
//

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

    func testNavToGame() {
        let app = XCUIApplication()
        loginToHomeScreen(app)
        
        
        XCTAssert(app.buttons["Wellness"].waitForExistence(timeout: 5))
        app.buttons["Wellness"].tap()
        
        XCTAssert(app.buttons["CogGameButton"].waitForExistence(timeout: 5))
        app.buttons["CogGameButton"].tap()
        
    }
    
    func testMatchGame() {
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
        
        
//        elementArray[0].tap()
//        elementArray[1].tap()
//
//        elementArray[0].tap()
//        elementArray[2].tap()
//
//        elementArray[0].tap()
//        elementArray[3].tap()

        
//        for i in 0..<elementArray.count {
//
//            for j in 0..<elementArray.count {
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
//
//                   var cell1 = elementArray[i]
//                    var cell2 = elementArray[j]
//                    cell1.tap()
//                    cell2.tap()
//
//                }
//
//            }
//
//        }
 
        
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
