//
//  SceneDelegateTests.swift
//  VKFeedAppTests
//
//  Created by Vadim Khomenok on 12.06.22.
//

import XCTest
import VKFeediOS
@testable import VKFeedApp

class SceneDelegateTests: XCTestCase {
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindowSpy()
        
        let sut = SceneDelegate()
        
        sut.window = window
        sut.configureScene()
        
        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected to make window key and visible")
    }
    
    func test_configureWindow_configuresRootViewController() {
        let sut = SceneDelegate()
        
        sut.window = UIWindow()
        sut.configureScene()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topController is ListViewController, "Expected a feed controller as top view controller, got \(String(describing: topController)) instead")
    }
    
    // MARK: - Helpers
    
    private class UIWindowSpy: UIWindow {
        var makeKeyAndVisibleCallCount: Int = 0
        
        override func makeKeyAndVisible() {
            makeKeyAndVisibleCallCount += 1
        }
    }
}
