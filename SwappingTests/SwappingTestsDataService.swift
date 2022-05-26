//
//  SwappingTestsDataService.swift
//  SwappingTests
//
//  Created by Ксения Каштанкина on 07.05.22.
//

import XCTest

@testable import Swapping

class SwappingTestsDataService: XCTestCase {
    
    
    var sut: Swapping.Category?
    
    var sutProduct: Product?

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = Category()
        sutProduct = Product(name: "product1", category: "clothe", image: nil, features: nil, description: "description of product")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }

    func testJsonCategoryDecode() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        let dictJson : [String: Any] = [
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
        let jsonData = try JSONSerialization.data(withJSONObject: dictJson)
        
        let object = try? JSONDecoder().decode(Category.self, from: jsonData)
        
        XCTAssertNotNil(object)
        
        sut?.name = "clothe"
        
       XCTAssertEqual(object, sut)
    }
    
    func testJsonProductGotten() throws {
        let json : [String: Any] = [
                  "image_url": "https://firebasestorage.googleapis.com:443/v0/b/swappingapp-c409e.appspot.com/o/systemImages%2Fclothe.jpeg?alt=media&token=56c9a7e9-703d-4d53-8955-18c1c405bf30",
                  "category": "clothe",
                  "name": "product1",
                  "description":  "description of product"
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        
        let object = try? JSONDecoder().decode(Product.self, from: jsonData)
        object?.id = "111"
        
        XCTAssertNotNil(object)
        
        sutProduct?.id = "111"
        
       XCTAssertEqual(sutProduct, object)
        XCTAssertEqual(object?.category, "clothe")
        XCTAssertEqual(object?.name, "product1")
        XCTAssertEqual(object?.productDescription, "description of product")

    }

}
