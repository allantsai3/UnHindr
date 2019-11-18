//
//  MedicationTests.swift
//  UnHindrTests
//
//  Created by ata87 on 2019-11-17.
//  Copyright © 2019 Sigma. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseAuth
@testable import UnHindr

class MedicationTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        let email = "unittestacc@gmail.com"
//        let password = "testtest"
//        //        var handle = AuthStateDidChangeListenerHandle?
//        Auth.auth().signIn(withEmail: email, password: password){ authResult, error in
//            if error != nil {
//                XCTFail("Unable to sign in")
//            }
//            Services.handle = Auth.auth().addStateDidChangeListener { (auth, user) in
//                Services.getDBUserRef(user, completionHandler: { (userRef) in
//                    guard userRef != nil else {
//                        XCTFail("Unable to get user reference")
//                        return
//                    }
//                    Services.userRef = userRef
//                })
//            }
//        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        Auth.auth().removeStateDidChangeListener(Services.handle!)
    }

    func test() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
