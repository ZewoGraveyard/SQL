//
//  SQLTests.swift
//  SQLTests
//
//  Created by David Ask on 23/12/15.
//  Copyright © 2015 Zewo. All rights reserved.
//

import XCTest
import SQL
import Core
import CURIParser

class SQLTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let q = SelectQuery(["name", "id"], from: "people")
            .condition("id") {
                id in
                
                id == 100
        }
        
        
        print(q.SQLQuery)
        print("!")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
