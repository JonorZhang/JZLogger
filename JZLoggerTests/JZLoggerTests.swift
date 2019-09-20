//
//  JZLoggerTests.swift
//  JZLoggerTests
//
//  Created by JonorZhang on 2019/8/20.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import XCTest
@testable import JZLogger

class JZLoggerTests: XCTestCase {
    
    let fl = JZFileLogger.shared

    override func setUp() {
        fl.insertText("hello, world1!")
        fl.insertText("hello, world2!")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testMakeLog() {
        let files = fl.getAllFileURLs()
        print(files.count)
        XCTAssert(files.count <= 30)
    }

    func testAllLogFiles() {
        guard let data = fl.readLogFile(fl.curLogFileURL),
            let str = String(data: data, encoding: .utf8) else {
            XCTAssert(false)
            return
        }
        print(str)
        XCTAssert(true)
    }
}
