//
//  AC3_2_InstaCats_2Tests.swift
//  AC3.2-InstaCats-2Tests
//
//  Created by Louis Tur on 10/10/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import XCTest
@testable import AC3_2_InstaCats_2

class AC3_2_InstaCats_2Tests: XCTestCase {
    
    let testInstaCatTableVC: InstaCatTableViewController = InstaCatTableViewController()
    
    let testName: String = "Insta Cat"
    let testID: Int = 99999
    let testURL: URL = URL(string: "http://www.google.com")!
    
    let testFileName: String = "test.json"
    let invalidFileName: String = "testing.json"
    let malformedFileName: String = "testedjson"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    // MARK: - InstaCats test -
    func testInitializerOfInstaCat() {
        let testInstaCat: InstaCat = InstaCat(name: testName, id: testID, instagramURL: testURL)
        
        XCTAssertTrue(testInstaCat.name == testName)
        XCTAssertTrue(testInstaCat.catID == testID)
        XCTAssertTrue(testInstaCat.instagramURL == testURL)
    }
    
    func testValidInstaCatDescription() {
        let testInstaCat: InstaCat = InstaCat(name: testName, id: testID, instagramURL: testURL)
        let expectedDescription: String = "Nice to me you, I'm \(testName)"
        
        XCTAssertTrue(testInstaCat.description == expectedDescription)
    }
    
    func testGettingInstaCatsFromData() {
        guard let testCats = InstaCatFactory.makeInstaCats(fileName: testFileName) else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(testCats.count == 3)
        XCTAssertTrue(testCats[0].name == "Nala Cat")
        XCTAssertTrue(testCats[1].catID == 002)
        XCTAssertTrue(testCats[2].instagramURL == URL(string: "https://www.instagram.com/grump_cat_/?hl=en"))
    }

    
    // MARK: - InstaDogs Tests - 
    func testInitializerOfInstaDog() {
        let components = self.testFileName.components(separatedBy: ".")
        guard let fileURL = Bundle.main.url(forResource: components.first, withExtension: components.last) else {
            XCTFail()
            return
        }
        
        if let validData: Data = try? Data(contentsOf: fileURL) {
            if let instaDogs: [InstaDog] = InstaDogFactory.manager.getInstaDogs(from: validData) {
                
                guard let onlyInstaDog = instaDogs.first else {
                    XCTFail("InstaDogFactory should generate the correct number of instaDogs from test data. Expected: 1, Actual: \(instaDogs.count)")
                    return
                }
                
                // properties
                XCTAssertTrue(onlyInstaDog.name == "Men's Wear Dog")
                XCTAssertTrue(onlyInstaDog.dogID == 001)
                XCTAssertTrue(onlyInstaDog.instagramURL == URL(string: "https://www.instagram.com/mensweardog/")!)
                XCTAssertTrue(onlyInstaDog.imageName == "mens_wear_dog.jpg")
                XCTAssertTrue(onlyInstaDog.followers > 0)
                XCTAssertTrue(onlyInstaDog.following > 0)
                XCTAssertTrue(onlyInstaDog.numberOfPosts > 0)
                
                // functions
                XCTAssertTrue(onlyInstaDog.formattedStats() == "Posts: \(onlyInstaDog.numberOfPosts)   Followers: \(onlyInstaDog.followers)   Following:\(onlyInstaDog.following)")
                
                XCTAssertNotNil(onlyInstaDog.profileImage())
                XCTAssertTrue(onlyInstaDog.profileImage() == UIImage(named: onlyInstaDog.imageName))
            }
        }
        
        
    }
}
