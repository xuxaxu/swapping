//
//  SwappingTests.swift
//  SwappingTests
//
//  Created by Ксения Каштанкина on 05.05.22.
//

import XCTest
import Foundation
import Firebase

@testable import Swapping


class SwappingTests: XCTestCase {

    var sut: imageWork?
    
    var sutDataBase : FireDataBase?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = imageWork()
        
        sutDataBase = FireDataBase(container: Container(), args: ())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        sutDataBase = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
         
        //given
        var size = UIImageView(image: UIImage(named: "launch"))
        var height = NSLayoutConstraint(item: size, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 250)
        var width = NSLayoutConstraint(item: size, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 250)
        
        //when
        imageWork.adjustImageView(imageView: &size, widthConstraint: &width, heightConstraint: &height)
        
        //then
        XCTAssertEqual(min(height.constant,width.constant), 250, "constraints adjust wrong")
    }
    
    func testAppUrls() throws {
        
        let _ = Database.database(url: "https://swappingapp-c409e-default-rtdb.europe-west1.firebasedatabase.app/")
        let _ = Storage.storage().reference(forURL: "gs://swappingapp-c409e.appspot.com/")

        
    }
    
    func testFireDataBaseGetDataForCategories() {
        let promise = expectation(description: "categories recieved")
        
        var categoriesCount = 0
        var nameOfFirstCategory: String?
        sutDataBase?.getData(path: "categories/") {dict  in
            categoriesCount = dict.count
            
            for (_, value) in dict {
                if let object = try? JSONDecoder().decode(Category.self, from: value) {
                    nameOfFirstCategory = object.name
                }
                break
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        XCTAssert(categoriesCount > 0)
        XCTAssertNotNil(nameOfFirstCategory)
    }
    
    func testFireDataBaseGetDataForProducts() {
        let promise = expectation(description: "products recieved")
    
        var productsCount = 0
        var nameOfFirstProduct: String?
        var categoryOfFirstProduct: String?
        
        sutDataBase?.getData(path: "products/"){dict in
            productsCount = dict.count
            
            for object in dict.values {
                if let product = try? JSONDecoder().decode(Product.self, from: object) {
                    nameOfFirstProduct = product.name
                    categoryOfFirstProduct = product.category
                }
                break
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 5)
        XCTAssert(productsCount > 0)
        XCTAssertNotNil(nameOfFirstProduct)
        XCTAssertNotNil(categoryOfFirstProduct)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTStorageMetric(), XCTMemoryMetric()]) {
            // Put the code you want to measure the time of here.
            sutDataBase?.getData(path: "products", complition: { dict in
                for object in dict.values {
                    if let _ = try? JSONDecoder().decode(Product.self, from: object) {
                        
                    }
                }
            })
        }
    }
    

}
