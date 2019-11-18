//
//  DatabaseTests.swift
//  UnHindrTests
//
//  Created by Allan on 2019-11-03.
//  Copyright © 2019 Sigma. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseAuth

class DatabaseTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let email = "unittestacc@gmail.com"
        let password = "testtest"
//        var handle = AuthStateDidChangeListenerHandle?
        Auth.auth().signIn(withEmail: email, password: password){ [weak self] authResult, error in
            if error != nil {
                XCTFail("Unable to sign in")
            }
            
            
//            handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
//            }
        }
        
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        //test log out
    }
    
    //tests profile and see if data can be stored and retrieved correctly
    func testSetProfile(){
    }
    
    //tests mood and see if data can be stored and retrieved correctly
    func testMoodSetData(){
        
    }
    
    func testMedicationSetData(){
        
    }
    
    // Test to see if logout is successful
    func testLogOut(){
        
    }
    
    //Logout of one user and login to another and see if fields change
    func testDataIsolation(){
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
