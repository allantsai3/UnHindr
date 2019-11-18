/*
 File: [MotorGameTests]
 Creators: [Jake]
 Date created: [17/11/2019]
 Date updated: [17/11/2019]
 Updater name: [Jake]
 File description: [Runs the Unit tests for the Motor Game]
 */

import SpriteKit
import CoreMotion
import Foundation
import XCTest

@testable import UnHindr

class MotorGameTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
