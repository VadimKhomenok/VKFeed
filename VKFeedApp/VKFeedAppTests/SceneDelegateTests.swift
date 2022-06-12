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
        let window = UIWindow()
        window.windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        
        let sut = SceneDelegate()
        
        sut.window = window
        sut.configureScene()
        
        XCTAssertTrue(window.isKeyWindow)
        XCTAssertFalse(window.isHidden)
    }
    
    func test_configureWindow_configuresRootViewController() {
        let sut = SceneDelegate()
        
        sut.window = UIWindow()
        sut.configureScene()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topController is FeedViewController, "Expected a feed controller as top view controller, got \(String(describing: topController)) instead")
    }
}
