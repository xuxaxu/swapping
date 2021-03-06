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
    
    var sutAuth: SwappingAuth?
    
    var container: Container = Container()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = imageWork()
        
        sutDataBase = FireDataBase(container: Container(), args: ())
        
        sutAuth = container.resolve(args: ())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        sutDataBase = nil
        sutAuth = nil
        try super.tearDownWithError()
    }

    //MARK: - testing work with images
    
    func testAdjuctImageView() throws {
         
        //given
        var size = UIImageView(image: UIImage(named: "launch"))
        var height = NSLayoutConstraint(item: size, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 250)
        var width = NSLayoutConstraint(item: size, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 250)
        
        //when
        imageWork.adjustImageView(imageView: &size, widthConstraint: &width, heightConstraint: &height)
        
        //then
        XCTAssertEqual(min(height.constant,width.constant), 250, "constraints adjust wrong")
    }
    
    //MARK: - test firebase connection and data
    
    func testAppUrls() throws {
        
        let _ = Database.database(url: "https://swappingapp-c409e-default-rtdb.europe-west1.firebasedatabase.app/")
        let _ = Storage.storage().reference(forURL: "gs://swappingapp-c409e.appspot.com/")

        
    }
    
    //MARK: - saving credentials
    func testSaving() {
        let testLogin = "ksukor@mail.ru"
        let testPassword = "123456"
        
        sutAuth?.authenticate(login: testLogin, password: testPassword, save: true)
        
        let saved = sutAuth?.getSavedPassword(login: testLogin)
        
        XCTAssertEqual(saved, testPassword)
    }
    
    func testAuthentication() {
        let testLogin = "ksukor@mail.ru"
        let testPassword = "123456"
        
        sutAuth?.authenticate(login: testLogin, password: testPassword, save: false)
        
        if sutAuth?.authenticated.value ?? true {
            XCTFail()
        }
    }

}
