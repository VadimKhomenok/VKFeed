//
//  SceneDelegateTests.swift
//  VKFeedAppUIAcceptanceTests
//
//  Created by Vadim Khomenok on 6.06.22.
//

import XCTest
@testable import VKFeedApp
import VKFeediOS

class SceneDelegateTests: XCTestCase {
    
    func test_sceneWillConnectToSession_configuresRootViewController() {
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
