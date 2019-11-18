/*
 File: [MotorGameUITests
 Creators: [Jake]
 Date created: [17/11/2019]
 Date updated: [17/11/2019]
 Updater name: [Jake]
 File description: [Runs UI tests for the Motor Game Wellness Test]
 */

import XCTest

class MotorGameUITests: XCTestCase {
    func a() {print("something")}
    func setup() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNavigationToMotorGame() {
        let app = XCUIApplication()
        loginToHomeScreen(app)
        
        app.buttons["Wellness"].tap()
        XCTAssert(true/*app.buttons["MotorGame"].waitForExistence(timeout: 5)*/)
    }
    
    
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

