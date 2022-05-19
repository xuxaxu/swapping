//
//  SwappingTestsDataService.swift
//  SwappingTests
//
//  Created by Ксения Каштанкина on 07.05.22.
//

import XCTest

@testable import Swapping

class SwappingTestsDataService: XCTestCase {
    
    
    var sut: DataService<DataObject>?

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = DataService(container: Container(), args: DataObject.self)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }

    func testJsonCategoryGotten() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        let _ : [String: Any] = [
                  "image_url": "https://firebasestorage.googleapis.com:443/v0/b/swappingapp-c409e.appspot.com/o/systemImages%2Fclothe.jpeg?alt=media&token=56c9a7e9-703d-4d53-8955-18c1c405bf30",
                  "men": [
                    "image_url": "https://firebasestorage.googleapis.com:443/v0/b/swappingapp-c409e.appspot.com/o/systemImages%2Fmen.jpeg?alt=media&token=f923f349-f4f6-4b02-8055-38686b559e6f",
                    "name": "men"
                  ],
                  "name": "clothe"
                  ,
                  "women": [
                    "image_url": "https://firebasestorage.googleapis.com:443/v0/b/swappingapp-c409e.appspot.com/o/systemImages%2Fwomen.jpeg?alt=media&token=dfebf00a-8943-485f-b521-c8564ed0dcaa",
                    "name": "women"
                  ]
        ]
        
        let promise = expectation(description: "categories decoded")
        
        var objectExample = DataObject()
        sut?.getData(ref: "categories/") { arrayOfObjects in
            for object in arrayOfObjects {
                if object.name == "clothe" {
                    objectExample = object
                    promise.fulfill()
                    break
                }
            }
        }
        
        wait(for: [promise], timeout: 50)
        
        let category = DataObject()
        category.name = "clothe"
        
       XCTAssertEqual(objectExample, category)
    }
    
    func testJsonProductGotten() throws {
        let json : [String: Any] = [
                  "image_url": "https://firebasestorage.googleapis.com:443/v0/b/swappingapp-c409e.appspot.com/o/systemImages%2Fclothe.jpeg?alt=media&token=56c9a7e9-703d-4d53-8955-18c1c405bf30",
                  "category": "clothe",
                  "name": "product1",
                  "description":  "description of product"
        ]
        let data = try JSONSerialization.data(withJSONObject: json)
        //sut?.jsonGotten(data: data, id: "111", kind: .product)
        
        let product = Product(name: "product1", category: "clothe", image: nil, features: nil, description: "description of product")
        product.id = "111"
        
       // XCTAssertEqual(sut?.products, [product])

    }
    
    func testGetRootCategories() {
        //let promise = expectation(description: "getting categories from firebase")
        sut?.getCategories(in: nil)
        
       // XCTAssertGreaterThan(sut!.categories.count, 1)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}