//
//  CodableCatalogStorageTests.swift
//  TMDBTests
//
//  Created by David Luna on 12/02/25.
//

import XCTest
import TMDB

class CodableCatalogStorage {
    
    private let storageURL: URL
    
    init(storageURL: URL) {
        self.storageURL = storageURL
    }
    
    
    private struct CatalogCache: Codable {
        let catalog: CodableCatalog
        let timestamp: Date
        
        init(catalog: CodableCatalog, timestamp: Date) {
            self.catalog = catalog
            self.timestamp = timestamp
        }
        
        var localCatalog: LocalCatalog {
            return LocalCatalog(page: catalog.page, totalPages: catalog.totalPages, movies: catalog.movies.map { $0.localMovie })
        }
    }
    
    private struct CodableCatalog: Codable {
        let page: Int
        let totalPages: Int
        let movies: [CodableMovie]
        
        init(_ catalog: LocalCatalog) {
            page = catalog.page
            totalPages = catalog.totalPages
            movies = catalog.movies.map( CodableMovie.init )
        }
    }
    
    struct CodableMovie: Codable {
        let id: Int
        let title: String
        let posterPath: String
        
        init(_ movie: LocalMovie) {
            id = movie.id
            title = movie.title
            posterPath = movie.posterPath
        }
        
        var localMovie: LocalMovie {
            return LocalMovie(id: id, title: title, posterPath: posterPath)
        }
    }
    
    func insert(catalog: LocalCatalog, timestamp: Date, completion: @escaping CatalogStore.StoreCompletion) {
        let encoder = JSONEncoder()
        let cache = CatalogCache(catalog: CodableCatalog(catalog), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storageURL)
        completion(nil)
    }
    
    func retrieve(completion: @escaping CatalogStore.RetrieveCompletion) {
        guard let data = try? Data(contentsOf: storageURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(CatalogCache.self, from: data)
        completion(.found(catalog: cache.localCatalog, timestamp: cache.timestamp))
    }
}

final class CodableCatalogStorageTests: XCTestCase {
    
    func test_GIVEN_cacheIsEmpty_WHEN_retrieveIsCalled_THEN_shouldDeliverEmpty() {
        let sut = buildSut()
        let expectation = expectation(description: expectationDescription())
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty catalog but got: \n\(String(describing: result))")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_GIVEN_cacheIsEmpty_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldAlwaysDeliverEmpty() {
        let sut = buildSut()
        let expectation = expectation(description: expectationDescription())
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty catalog but got: \n\(firstResult) \(secondResult)")
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_GIVEN_localCatalogAndTimestamp_WHEN_retrieveIsCalledAfterInsertingCache_THEN_shouldDeliverInsertedValues() {
        let sut = buildSut()
        let localCatalog = createCatalog().toLocal()
        let timestamp = Date()
        let expectation = expectation(description: expectationDescription())
        
        sut.insert(catalog: localCatalog, timestamp: timestamp) { insertError in
            XCTAssertNil(insertError, "Failed to insert catalog")
            
            if insertError == nil {
                sut.retrieve { retrieveResult in
                    switch retrieveResult{
                    case let .found(catalogResult, timestampResult):
                        XCTAssertEqual(catalogResult, localCatalog)
                        XCTAssertEqual(timestampResult, timestamp)
                    default:
                        XCTFail("Expected catalog but got: \(retrieveResult)")
                    }
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func test_GIVEN_localCatalogAndTimestamp_WHEN_retrieveIsCalledMultipleTimesFromNonEmptyCache_THEN_shouldDeliverInsertedValues() {
        let sut = buildSut()
        let localCatalog = createCatalog().toLocal()
        let timestamp = Date()
        let expectation = expectation(description: expectationDescription())
        
        sut.insert(catalog: localCatalog, timestamp: timestamp) { insertError in
            XCTAssertNil(insertError, "Failed to insert catalog")
            
            sut.retrieve { firstRetrieveResult in
                sut.retrieve { secondRetrieveResult in
                    switch (firstRetrieveResult, secondRetrieveResult) {
                    case let (.found(firstCatalog, firstTimestamp), .found(secondCatalog, secondTimestamp)):
                        XCTAssertEqual(firstCatalog, localCatalog)
                        XCTAssertEqual(firstTimestamp, timestamp)
                        XCTAssertEqual(secondCatalog, localCatalog)
                        XCTAssertEqual(secondTimestamp, timestamp)
                    default:
                        XCTFail("Expected found result with inserted \(localCatalog) and \(timestamp) but got \(firstRetrieveResult) and \(secondRetrieveResult)")
                    }
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    

}


extension CodableCatalogStorageTests {
    
    override func setUp() {
        super.setUp()
        clearStorage()
    }
    
    override func tearDown() {
        super.tearDown()
        clearStorage()
    }
    
    func buildSut(file: StaticString = #filePath, line: UInt = #line) -> CodableCatalogStorage {
        let sut = CodableCatalogStorage(storageURL: testStorageURL())
        trackMemoryLeaks(instanceOf: sut, file: file, line: line)
        return sut
    }
    
    private func clearStorage() {
        try? FileManager.default.removeItem(at: testStorageURL())
    }
    
    private func testStorageURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
