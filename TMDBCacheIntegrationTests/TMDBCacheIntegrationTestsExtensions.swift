//
//  File.swift
//  TMDB
//
//  Created by David Luna on 16/02/25.
//

import XCTest
import TMDB

extension TMDBCacheIntegrationTests {
    
    func buildSut(file: StaticString = #filePath, line: UInt = #line) -> LocalCatalogLoader {
        let storeBundle = Bundle(for: CoreDataCatalogStore.self)
        let storeURL = storageURLTests()
        let store = try! CoreDataCatalogStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalCatalogLoader(store: store, currentDate: { Date.init() })
        
        trackMemoryLeaks(instanceOf: store, file: file, line: line)
        trackMemoryLeaks(instanceOf: sut, file: file, line: line)
        
        return sut
    }
    
    private func storageURLTests() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    func clearStorage() {
        try? FileManager.default.removeItem(at: storageURLTests())
    }
    
    func assertThatLoadResult(
        from sut: LocalCatalogLoader
    ) -> CatalogResult? {
        let expectation = expectation(description: "assertThatLoadResult description")
        
        var receivedResult: CatalogResult?
        sut.load { result in
            receivedResult = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        return receivedResult
    }
    
    func assertThatSaveResult(
        _ catalog: Catalog,
        from sut: LocalCatalogLoader
    ) -> CatalogStore.StoreResult? {
        let expectation = expectation(description: "assertThatSaveResult description")
        
        var receivedResult: CatalogStore.StoreResult?
        sut.save(catalog) { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        return receivedResult
    }
    
    
}
