//
//  ListSnapshotTests.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 22.06.22.
//

import XCTest
import VKFeediOS
@testable import VKFeed

class ListSnapshotTests: XCTestCase {
    
    func test_emptyList_snapshot() {
        let sut = makeSUT()
        
        sut.display(emptyList())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_LIST_dark")
    }
    
    func test_listError_snapshot() {
        let sut = makeSUT()
        
        sut.display(ResourceLoadErrorViewModel(message: "This is a\nmulti-line\nerror message"))
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let controller = ListViewController()
        
        trackForMemoryLeaks(controller)
        
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        
        return controller
    }
    
    private func emptyList() -> [CellController] {
        return []
    }
}
