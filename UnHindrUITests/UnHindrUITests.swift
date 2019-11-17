//
//  UnHindrUITests.swift
//  UnHindrUITests
//
//  Created by Allan on 2019-10-28.
//  Copyright © 2019 Sigma. All rights reserved.
//

import XCTest

class UnHindrUITests: XCTestCase {
    func a() { print ("something") }
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
    
    // tests textfields and buttons
    func testLoginPage() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        XCTAssert(app.textFields["Email"].exists)
        XCTAssert(app.secureTextFields["Password"].exists)
        XCTAssert(app.buttons["Login Button"].exists)
    }
    
    //tests all input fields and buttons
    func testNavigationToProfile(){
        let app = XCUIApplication()
        loginToHomeScreen(app)

        XCTAssert(app.buttons["Profile"].exists)
        app.buttons["Profile"].tap()
        //Check to see if all element exists
        XCTAssert(app.textFields["First Name"].exists)
        XCTAssert(app.textFields["Last Name"].exists)
        XCTAssert(app.textFields["Email Name"].exists)
        XCTAssert(app.textFields["Date of Birth"].exists)
        XCTAssert(app.textFields["Cell"].exists)
        XCTAssert(app.textFields["Gender"].exists)
        XCTAssert(app.textFields["Address"].exists)
        XCTAssert(app.buttons["Save Button"].exists)
        XCTAssert(app.buttons["Back Button"].exists)
        
        //TODO: test fields  with save button
        
        //Check for back button
        app.buttons["Back Button"].tap()
        //Check if back at home screen
        XCTAssert(app.buttons["Profile"].waitForExistence(timeout: 5))
        
    }
    
    // tests all input fields and buttons
    func testNavigationToWellness(){
        let app = XCUIApplication()
        loginToHomeScreen(app)
        
        // Constants for user selection
        let stronglyAgreeButton = app.buttons["Strongly Agree"]
        let agreeButton = app.buttons["Agree"]
        let neutralButton = app.buttons["Neutral"]
        let disagreeButton = app.buttons["Disagree"]
        let stronglyDisagreeButton = app.buttons["Strongly Disagree"]
        let nextButton = app.buttons["Next"]
        
        //Check if wellness test exists and navigate
        XCTAssert(app.buttons["Wellness"].waitForExistence(timeout: 5))
        app.buttons["Wellness"].tap()
        
        // Wellness page homescreen
        XCTAssert(app.buttons["Mood Survey Button"].waitForExistence(timeout: 5))
        app.buttons["Mood Survey Button"].tap()
        
        // Q1
        XCTAssert(stronglyAgreeButton.waitForExistence(timeout: 5))
        XCTAssert(stronglyAgreeButton.exists)
        XCTAssert(agreeButton.exists)
        XCTAssert(neutralButton.exists)
        XCTAssert(disagreeButton.exists)
        XCTAssert(stronglyDisagreeButton.exists)
        stronglyAgreeButton.tap()
        nextButton.tap()
        
        //Q2
        XCTAssert(stronglyAgreeButton.waitForExistence(timeout: 5))
        XCTAssert(stronglyAgreeButton.exists)
        XCTAssert(agreeButton.exists)
        XCTAssert(neutralButton.exists)
        XCTAssert(disagreeButton.exists)
        XCTAssert(stronglyDisagreeButton.exists)
        stronglyDisagreeButton.tap()
        nextButton.tap()
        
        //Q3
        XCTAssert(stronglyAgreeButton.waitForExistence(timeout: 5))
        XCTAssert(stronglyAgreeButton.exists)
        XCTAssert(agreeButton.exists)
        XCTAssert(neutralButton.exists)
        XCTAssert(disagreeButton.exists)
        XCTAssert(stronglyDisagreeButton.exists)
        agreeButton.tap()
        nextButton.tap()
        
        //Q4
        XCTAssert(stronglyAgreeButton.waitForExistence(timeout: 5))
        XCTAssert(stronglyAgreeButton.exists)
        XCTAssert(agreeButton.exists)
        XCTAssert(neutralButton.exists)
        XCTAssert(disagreeButton.exists)
        XCTAssert(stronglyDisagreeButton.exists)
        neutralButton.tap()
        nextButton.tap()
        
        //Q5
        XCTAssert(stronglyAgreeButton.waitForExistence(timeout: 5))
        XCTAssert(stronglyAgreeButton.exists)
        XCTAssert(agreeButton.exists)
        XCTAssert(neutralButton.exists)
        XCTAssert(disagreeButton.exists)
        XCTAssert(stronglyDisagreeButton.exists)
        
        
        //Finish the test
        stronglyDisagreeButton.tap()
        app.buttons["Done!"].tap()
        
        //Check if back at home screen
        XCTAssert(app.buttons["Wellness"].waitForExistence(timeout: 5))
        
    }
    
    //tests all input fields and buttons on Medication
    func testNavigationToMedication(){
        let app = XCUIApplication()
        loginToHomeScreen(app)
        
        //Navigate into meds home page
        XCTAssert(app.buttons["Medication"].waitForExistence(timeout: 5))
        app.buttons["Medication"].tap()
        
//        //Check medication graph
//        XCTAssert(app.buttons["MyMedsButton"].waitForExistence(timeout: 5))
//        app.buttons["MyMedsButton"].tap()
//
//        // TODO: Additional checks with medication graph
//
//        XCTAssert(app.buttons["MyLogButton"].waitForExistence(timeout: 5))
//        app.buttons["MyLogButton"].tap()
        
        //Navigate to add new medication plan
        XCTAssert(app.buttons["Add new"].exists)
        app.buttons["Add new"].tap()
        
        //Check under add new medication plan
        XCTAssert(app.textFields["Medication Name"].exists)
        
//        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element(boundBy: 2).children(matching: .other).element
//        let stepper = element.children(matching: .stepper).element(boundBy: 0)
//        XCTAssert(stepper.buttons["Increment"].exists)
//        XCTAssert(stepper.buttons["Decrement"].exists)
//
//        let stepper2 = element.children(matching: .stepper).element(boundBy: 1)
//        XCTAssert(stepper2.buttons["Increment"].exists)
//        XCTAssert(stepper2.buttons["Decrement"].exists)
        
        
//        XCTAssert(app.buttons["monday"].exists)
//        XCTAssert(app.buttons["tuesday"].exists)
//        XCTAssert(app.buttons["wednesday"].exists)
//        XCTAssert(app.buttons["thursday"].exists)
//        XCTAssert(app.buttons["friday"].exists)
//        XCTAssert(app.buttons["saturday"].exists)
//        XCTAssert(app.buttons["sunday"].exists)
//        XCTAssert(app.textFields["00:00"].exists)
//        XCTAssert(app.buttons["Add"].exists)
//        XCTAssert(app.buttons["Cancel"].exists)
        
//        //Navigate back to meds plan home page
//        app.buttons["Cancel"].tap()
//        XCTAssert(app.buttons["Remove"].exists)
//        XCTAssert(app.buttons["Full med schedule"].exists)
//        XCTAssert(app.buttons["home white"].exists)
//        
//        //check for navigation back to home screen
//        app.buttons["home white"].tap()
//        XCTAssert(app.buttons["Medication"].waitForExistence(timeout: 5))
        
    }
    
    // tests all fields and buttons under options
    func testNavigationToOptions(){
        let app = XCUIApplication()
        loginToHomeScreen(app)
        
        let optionsButton = app.buttons["Options"]
        XCTAssert(optionsButton.waitForExistence(timeout: 5))
        optionsButton.tap()
        XCTAssert(app.buttons["home white"].exists)
        app.buttons["home white"].tap()
        optionsButton.tap()
        app.buttons["Button"].tap()
        
        XCTAssert(app.textFields["Email"].exists)
    }
    
    //test the scroll view in the profile
    func testProfileScrollView(){
        let app = XCUIApplication()
        loginToHomeScreen(app)
        app.buttons["CaregiverProfile"].tap()
        
         XCTAssert(app.buttons["Save Button"].exists)
        let scrollViewsQuery = app.scrollViews
        let element = scrollViewsQuery.otherElements.containing(.image, identifier:"Menu BG").children(matching: .other).element
        element.swipeUp()
        
        let elementsQuery = scrollViewsQuery.otherElements
        let backButtonButton = elementsQuery.buttons["Back Button"]
        backButtonButton.tap()
        app.buttons["Profile"].tap()
        
        let dateOfBirthTextField = elementsQuery.textFields["Date of Birth"]
        dateOfBirthTextField.swipeUp()
        elementsQuery.textFields["City"].tap()
        elementsQuery.textFields["Country"].tap()
        elementsQuery.textFields["Address"].tap()
        elementsQuery.textFields["Gender"].tap()
        elementsQuery.textFields["Cell"].tap()
        dateOfBirthTextField.tap()
        
        let emailNameTextField = elementsQuery.textFields["Email Name"]
        emailNameTextField.tap()
        element.swipeDown()
        element.tap()
        emailNameTextField.tap()
        elementsQuery.textFields["Last Name"].tap()
        elementsQuery.textFields["First Name"].tap()
        element.swipeUp()
        elementsQuery.buttons["Save Button"].tap()
        backButtonButton.tap()
        
        
    }
    
    
    // MARK: - Helper Functions
    // Input:
    //      1. Current application instance
    // Output:
    //      1. Home screen with wait (Warning: dependent on profile button)
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
