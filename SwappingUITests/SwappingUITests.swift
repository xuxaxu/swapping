//
//  SwappingUITests.swift
//  SwappingUITests
//
//  Created by Ксения Каштанкина on 08.05.22.
//

import XCTest

class SwappingUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testProductVC() {
                
        app.navigationBars["Welcome"].buttons["Cancel"].tap()
        
        let cellsQuery = app.collectionViews.cells
        if cellsQuery.otherElements.count > 0, cellsQuery.otherElements.firstMatch.images.count > 0 {
            cellsQuery.otherElements.firstMatch.images.firstMatch.tap()
        }
        
        app.tabBars["Tab Bar"].buttons["Categories"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.cells.firstMatch.tap()
        
        
    }
    
    func testAddingProduct() {
        
        
        app.navigationBars["Welcome"].buttons["Cancel"].tap()
        app.navigationBars["Swapping.ProductView"].buttons["Add"].tap()
        app.textFields["short description"].tap()
        
        let categoryOfProductTextField = app.textFields["category of product"]
        categoryOfProductTextField.tap()
        
        app.pickerWheels.firstMatch.tap()
        app.images["camera.fill.badge.ellipsis"].tap()
        app.scrollViews.otherElements.images.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Done"]/*[[".buttons[\"Done\"].staticTexts[\"Done\"]",".staticTexts[\"Done\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
    }
    
    func testAddingCategory() {
        
        app.navigationBars["Welcome"].buttons["Cancel"].tap()
        app.tabBars["Tab Bar"].buttons["Categories"].tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["art"]/*[[".cells.staticTexts[\"art\"]",".staticTexts[\"art\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Swapping.CatalogVC"].buttons["Add"].tap()
        app.textFields["name of category"].tap()
        app.images["camera.fill.badge.ellipsis"].tap()
        
        app.scrollViews.otherElements.images.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Done"]/*[[".buttons[\"Done\"].staticTexts[\"Done\"]",".staticTexts[\"Done\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
    }
    
}
