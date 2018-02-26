//
//  SCAssignmentTests.swift
//  SCAssignmentTests
//
//  Created by arati mohanty on 2/26/18.
//  Copyright © 2018 arati mohanty. All rights reserved.
//

import XCTest
@testable import SCAssignment

class SCAssignmentTests: XCTestCase {
    
    var controllerUnderTest: ViewController!
    var testNetworkManager: NetworkManager!
    var testSession: URLSession!
    
    override func setUp() {
        super.setUp()
        controllerUnderTest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        testNetworkManager = NetworkManager()
        testSession = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    override func tearDown() {
        controllerUnderTest = nil
        testSession = nil
        super.tearDown()
    }
    
    func testViewLoads() {
        XCTAssertNotNil(controllerUnderTest.view, "View not initiated properly")
    }
    
    func testViewControllerHasTableView() {
        let subViews = controllerUnderTest.view.subviews
        XCTAssertTrue(subViews.contains(controllerUnderTest.listTable), "ViewController should have outlet set for listTable")
    }
    
    func testViewControllerTableViewLoads() {
        testViewControllerHasTableView()
        XCTAssertNotNil(controllerUnderTest.listTable, "TableView not initiated properly")
    }
    
    func testThatViewConformsToUITableViewDataSource() {
        XCTAssertTrue(controllerUnderTest.conforms(to: UITableViewDataSource.self), "View does not conform to UITableView datasource")
    }
    
    func testThatViewConformsToUITableViewDelegate() {
        XCTAssertTrue(controllerUnderTest.conforms(to: UITableViewDelegate.self), "View does not conform to UITableView delegate")
    }
    
    func testGetDataFromServer() {
        controllerUnderTest.getDataFromServer()
    }
    
    func testThatViewConformsToNetworkManagerDelegate() {
        XCTAssertTrue(controllerUnderTest.conforms(to: NetworkmanagerDelegate.self), "View does not conform to NetworkmanagerDelegate")
    }
    
    func testTableViewNumberOfSections() {
        testViewControllerHasTableView()
        
        let expectedSections = 1
        XCTAssertTrue(controllerUnderTest.listTable.numberOfSections == expectedSections, "Table has \(controllerUnderTest.listTable.numberOfSections) sections but it should have \(expectedSections)")
    }
    
    func testTableViewNumberOfRowsInSection() {
        testViewControllerHasTableView()
        let expectedRows = 10
        XCTAssertTrue(controllerUnderTest.listTable.numberOfRows(inSection: 0) == expectedRows, "Table has \(controllerUnderTest.listTable.numberOfRows(inSection: 0)) sections but it should have \(expectedRows)")
    }
    
    func testTableViewHeightForRowAtIndexPath() {
        testViewControllerHasTableView()
        
        let expectedHeight = 50.0 as CGFloat
        let actualHeight = controllerUnderTest.listTable.rowHeight
        XCTAssertEqual(expectedHeight, actualHeight, "Cell should have \(expectedHeight) height, but they have \(actualHeight)")
    }
    
    func testTableViewCellCreateCellsWithReuseIdentifier() {
        testViewControllerHasTableView()
        _ = NSIndexPath.init(row: 0, section: 0)
        //        let cell = controllerUnderTest.listTable.cellForRow(at: indexPath as IndexPath)
        //        let expectedReuseIdentifier = "CellIdentifier"
        //        XCTAssertTrue(cell?.reuseIdentifier == expectedReuseIdentifier, "Table does not create reusable cells");
    }
    
    func testNetworkManagerGetData() {
        testNetworkManager.getData(urlString: "https://dog.ceo/api/breeds/list/all")
    }
    
    func testGetData() {
        let urlString = "https://dog.ceo/api/breeds/list/all"
        
        let promise = expectation(description: "Valid response")
        let url = NSURL(string: urlString)
        XCTAssertNotNil(url, "The URL not created")
        
        
        let urlRequest = NSURLRequest(url: url! as URL)
        let task = testSession.dataTask(with: urlRequest as URLRequest, completionHandler: {(data, response, error) in
            
            guard error == nil else {
                XCTFail("error while getting Data from server \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard let responseData = data else {
                XCTFail("Error: did not receive data")
                return
            }
            
            do {
                let responseFromServer = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject]
                if (responseFromServer) == nil {
                    XCTFail("error trying to convert data to JSON")
                }
                
                self.testNetworkManager.delegate = self as? NetworkmanagerDelegate
                self.testNetworkManager.delegate?.dataFromServer(response: responseFromServer!)
                
                promise.fulfill()
            }
            catch  {
                XCTFail("error trying to convert data to JSON")
            }
        })
        task.resume()
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func dataFromServer(response: [String : AnyObject]) {
        
    }
    
    func errorFromServer(error:NSError) {
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
