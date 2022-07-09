//
//  VKFeedCacheIntegrationTests.swift
//  VKFeedCacheIntegrationTests
//
//  Created by Vadim Khomenok on 25.04.22.
//

import XCTest
import VKFeed

class VKFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_loadFeed_deliversNoItemsOnEmptyCache() {
        let feedLoader = makeFeedLoader()
        
        expect(feedLoader, toLoad: [])
    }
    
    func test_loadFeed_deliversItemsSavedOnSeparateInstances() {
        let feedLoaderForSave = makeFeedLoader()
        let feedLoaderForLoad = makeFeedLoader()
        let feed = makeUniqueImageFeed().models
        
        save(feed, with: feedLoaderForSave)
        
        expect(feedLoaderForLoad, toLoad: feed)
    }
    
    func test_saveFeed_overridesCacheSavedOnSeparateInstances() {
        let firstSaveFeedLoader = makeFeedLoader()
        let secondSaveFeedLoader = makeFeedLoader()
        let feedLoaderForLoad = makeFeedLoader()
        let firstFeed = makeUniqueImageFeed().models
        let latestFeed = makeUniqueImageFeed().models
        
        save(firstFeed, with: firstSaveFeedLoader)
        save(latestFeed, with: secondSaveFeedLoader)

        expect(feedLoaderForLoad, toLoad: latestFeed)
    }
    
    
    // MARK: - LocalFeedImageDataLoader Tests
    
    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let imageLoaderToPerformSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        
        let image = makeUniqueImage()
        
        let data = anyData()
        let url = anyURL()
   
        save([image], with: feedLoader)
        save(data, for: url, with: imageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, toLoad: data, for: url)
    }
    
    func test_saveImageData_overridesSavedImageDataOnASeparateInstance() {
        let imageLoaderToPerformFirstSave = makeImageLoader()
        let imageLoaderToPerformLastSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let image = makeUniqueImage()
        let firstImageData = Data("first".utf8)
        let lastImageData = Data("last".utf8)
        
        save([image], with: feedLoader)
        save(firstImageData, for: image.url, with: imageLoaderToPerformFirstSave)
        save(lastImageData, for: image.url, with: imageLoaderToPerformLastSave)
        

        expect(imageLoaderToPerformLoad, toLoad: lastImageData, for: image.url)
    }
    
    func test_validateFeedCache_doesNotDeleteRecentlySavedFeed() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformValidation = makeFeedLoader()
        let feed = makeUniqueImageFeed().models
        
        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)
        
        expect(feedLoaderToPerformSave, toLoad: feed)
    }
    
    func test_validateFeedCache_deletesFeedSavedInADistantPast() {
        let feedLoaderToPerformSave = makeFeedLoader(currentDate: Date.distantPast)
        let feedLoaderToPerformValidation = makeFeedLoader()
        let feed = makeUniqueImageFeed().models
        
        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)
        
        expect(feedLoaderToPerformSave, toLoad: [])
    }

    
    // MARK: - Helpers
    
    private func makeFeedLoader(currentDate: Date = Date(), file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: { currentDate })
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func makeImageLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedImageDataLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut    
    }
    
    private func save(_ feed: [FeedImage], with sut: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let expectation = expectation(description: "Wait for save to complete")
        sut.save(feed) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save feed successfully, got error: \(error)", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let expectation = expectation(description: "Wait for load to complete")
        sut.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, expectedFeed, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected success with feed, received failure with \(error) instead", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func save(_ data: Data, for url: URL, with loader: LocalFeedImageDataLoader, file: StaticString = #file, line: UInt = #line) {
        do {
            try loader.save(data, for: url)
        } catch {
            XCTFail("Expected to save image data successfully, got error: \(error)", file: file, line: line)
        }
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .success(loadedData):
                XCTAssertEqual(loadedData, expectedData, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful image data result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func validateCache(with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
            let saveExp = expectation(description: "Wait for save completion")
            loader.validateCache() { result in
                if case let Result.failure(error) = result {
                    XCTFail("Expected to validate feed successfully, got error: \(error)", file: file, line: line)
                }
                saveExp.fulfill()
            }
            wait(for: [saveExp], timeout: 1.0)
        }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificStoreURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
