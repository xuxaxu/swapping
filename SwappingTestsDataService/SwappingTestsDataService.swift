//
//  SwappingTestsDataService.swift
//  SwappingTestsDataService
//
//  Created by Ксения Каштанкина on 19.05.22.
//

import XCTest
import Firebase

@testable import Swapping

class SwappingTestsDataService: XCTestCase {

    var sut : ProductListVM?
    var container: Container?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        container = Container()
        sut = container?.resolve(args: ())
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        
        sut?.products = [Product(name: "some clothe", category: "clothe", image: nil, features: nil, description: "description clothe"),
        Product(name: "some gadjet", category: "gadjets", image: nil, features: nil, description: "description gadjet")]
        
        sut?.choosenCategory = "clothe"
        
        /*
        let promise = expectation(description: "get categories")
        
        sut?.menuCategories.bind({ dict in
            promise.fulfill()
        })
        
        sut?.getAllCategories()
        
        wait(for: [promise], timeout: 15)
        */
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    
}
