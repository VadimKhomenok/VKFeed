//
//  CoreDataFeedImageDataStoreTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 31.05.22.
//

import VKFeed
import XCTest

class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()

        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = anyURL()
        let nonMatchingURL = URL(string: "http://another-url.com")!

        insert(anyData(), for: url, into: sut)

        expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
    }
    
    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() {
        let sut = makeSUT()
        let storedData = anyData()
        let matchingUrl = anyURL()
        
        insert(storedData, for: matchingUrl, into: sut)
        
        expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingUrl)
    }
    
    func test_retrieveImageData_deliversLastInsertedValueOverwritingPreviousValues() {
        let sut = makeSUT()
        let firstData = Data("Initial_data".utf8)
        let secondData = Data("Second_data".utf8)
        let lastData = Data("Last_data".utf8)
        
        let matchingUrl = anyURL()
        
        insert(firstData, for: matchingUrl, into: sut)
        insert(secondData, for: matchingUrl, into: sut)
        insert(lastData, for: matchingUrl, into: sut)
        
        expect(sut, toCompleteRetrievalWith: found(lastData), for: matchingUrl)
    }
    
    func test_sideEffects_runSerially() {
        let sut = makeSUT()
        let url = anyURL()

        let op1 = expectation(description: "Operation 1")
        sut.insert([localImage(url: url)], timestamp: Date()) { _ in op1.fulfill() }

        let op2 = expectation(description: "Operation 2")
        sut.insert(anyData(), for: url) { _ in op2.fulfill() }

        let op3 = expectation(description: "Operation 3")
        sut.insert(anyData(), for: url) { _ in op3.fulfill() }

        wait(for: [op1, op2, op3], timeout: 5.0, enforceOrder: true)
    }
    

    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func found(_ data: Data) -> FeedImageDataStore.RetrievalResult {
        return .success(data)
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
    
    private func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL,  file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success( receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        let image = localImage(url: url)
        
        sut.insert([image], timestamp: Date()) { result in
            switch result {
            case let .failure(error):
                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
                exp.fulfill()
                
            case .success:
                sut.insert(data, for: url) { result in
                    if case let Result.failure(error) = result {
                        XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                    }
                    
                    exp.fulfill()
                }
            }
        }

        wait(for: [exp], timeout: 1.0)
    }
}
