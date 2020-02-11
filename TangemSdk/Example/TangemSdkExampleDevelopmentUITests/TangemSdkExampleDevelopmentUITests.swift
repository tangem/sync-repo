//
//  TangemSdkExampleDevelopmentUITests.swift
//  TangemSdkExampleDevelopmentUITests
//
//  Created by Регина Латыпова on 11/02/2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import XCTest


class TangemSdkExampleDevelopmentUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launch()
        RobotApi().select(card: .red)

    }

    override func tearDown() {
        RobotApi().select(card: .none)
    }
    
    func testExample() {
        expectationAction(identifier: "ScanCardButton", timeout: 10)
        RobotApi().select(card: .none)
    }
    
    func expectationAction(identifier: String, timeout: TimeInterval) {
        print("", identifier, "Tap")
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: XCUIApplication().buttons[identifier])
        waitForExpectations(timeout: timeout, handler: nil)
        XCUIApplication().buttons[identifier].tap()
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
