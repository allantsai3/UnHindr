/*
 File: [MotGameUITests]
 Creators: [Jake]
 Date created: [17/11/2019]
 Date updated: [17/11/2019]
 Updater name: [Jake]
 File description: [Runs the UI tests for the Motor Game]
 */

import XCTest
@testable import UnHindr

class MotGameUITests: XCTestCase {

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
    
    // MARK: - Test navigation to Motor Game from login
    // Input:
    //      1. None
    // Output:
    //      1. Wellness Test screen with Motor Game button present
    func testNavigationToMotorGame() {
        let app = XCUIApplication()
        loginToHomeScreen(app)
        
        app.buttons["Wellness"].tap()
        XCTAssert(app.buttons["MotorGameButton"].waitForExistence(timeout: 5))
    }
    
    // MARK: - Test Home Button in Motor Game
    // Input:
    //      1. None
    // Output:
    //      1. Motor Game is entered, Home Button is pressed
    func testMotorGameHomeButton() {
        testNavigationToMotorGame()
        let app = XCUIApplication()
        app.buttons["MotorGameButton"].tap()
        XCTAssert(app.buttons["MotorGameHomeButton"].waitForExistence(timeout: 5))
        app.buttons["MotorGameHomeButton"].tap()
        XCTAssert(app.buttons["Wellness"].waitForExistence(timeout: 5))
    }
    
    // MARK: - Test that start label text appears upon entering the game
    // Input:
    //      1. None
    // Output:
    //      1. Motor Game is entered, start label text appears
    func testStartLabelText() {
        testNavigationToMotorGame()
        let app = XCUIApplication()
        app.buttons["MotorGameButton"].tap()
        XCTAssert(app.staticTexts["StartGameLabel"].waitForExistence(timeout: 5))
    }
    
    // MARK: - Test that the end label text and retry and quit buttons appear upon finishing the game
    // Input:
    //      1. None
    // Output:
    //      1. Motor Game is finished, end label text, retry, and quit buttons appear
    func testEndGameFeatureAppearances() {
        testStartLabelText()
        let app = XCUIApplication()
        app.staticTexts["StartGameLabel"].tap()
        XCTAssert(app.staticTexts["EndGameLabel"].waitForExistence(timeout: 5))
        XCTAssert(app.buttons["RestartButton"].waitForExistence(timeout: 5))
        XCTAssert(app.buttons["QuitButton"].waitForExistence(timeout: 5))
    }

    // MARK: - Helper Functions
    // Input:
    //      1. Current application instance
    // Output:
    //      1. Home screen with wait
    func loginToHomeScreen(_ app: XCUIApplication){
        // Login to the home screen
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("unittestacc@gmail.com\n")
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("testtest\n")
        app.buttons["Login Button"].tap()
        //Wait
        XCTAssert(app.buttons["Wellness"].waitForExistence(timeout: 5))
        
        
    }

}

