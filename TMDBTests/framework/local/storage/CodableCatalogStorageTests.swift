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
    
    private struct CodableMovie: Codable {
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
        do {
            let encoder = JSONEncoder()
            let cache = CatalogCache(catalog: CodableCatalog(catalog), timestamp: timestamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storageURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func retrieve(completion: @escaping CatalogStore.RetrieveCompletion) {
        guard let data = try? Data(contentsOf: storageURL) else {
            return completion(.empty)
        }
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(CatalogCache.self, from: data)
            completion(.found(catalog: cache.localCatalog, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }

    }
}

final class CodableCatalogStorageTests: XCTestCase {
    
    func test_GIVEN_cacheIsEmpty_WHEN_retrieveIsCalled_THEN_shouldDeliverEmpty() {
        let sut = buildSut()
        assertThatRetrieveResult(sut).isEqual(to: .empty)
    }
    
    func test_GIVEN_cacheIsEmpty_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldAlwaysDeliverEmpty() {
        let sut = buildSut()
        
        assertThatRetrieveResult(sut).isEqual(to: .empty)
        assertThatRetrieveResult(sut).isEqual(to: .empty)
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_retrieveIsCalled_THEN_shouldDeliverFoundValues() {
        let sut = buildSut()
        let localCatalog = createCatalog().toLocal()
        let timestamp = Date()
        
        assertThatInsertResult(with: (localCatalog, timestamp), sut).isNil()
        
        assertThatRetrieveResult(sut).isEqual(to: .found(catalog: localCatalog, timestamp: timestamp))
    }
    
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldDeliverSameFoundValues() {
        let sut = buildSut()
        let localCatalog = createCatalog().toLocal()
        let timestamp = Date()
        
        assertThatInsertResult(with: (localCatalog, timestamp), sut).isNil()
        assertThatRetrieveResult(sut).isEqual(to: .found(catalog: localCatalog, timestamp: timestamp))
        assertThatRetrieveResult(sut).isEqual(to: .found(catalog: localCatalog, timestamp: timestamp))
    }
    
    func test_GIVEN_cacheDataIsNotValid_WHEN_retrieveIsCalled_THEN_shouldDeliverFailureWithError() {
        let sut = buildSut()
        let expectedError = DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON."))
        
        try! "invalid data".write(to: testStorageURL(), atomically: false, encoding: .utf8)
        
        assertThatRetrieveResult(sut).isEqual(to: .failure(expectedError))
    }
    
    func test_GIVEN_cacheDataIsNotValid_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldDeliverFailureWithError() {
        let sut = buildSut()
        let expectedError = DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON."))
        
        try! "invalid data".write(to: testStorageURL(), atomically: false, encoding: .utf8)
        
        assertThatRetrieveResult(sut).isEqual(to: .failure(expectedError))
        assertThatRetrieveResult(sut).isEqual(to: .failure(expectedError))
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_insertIsCalled_THEN_shouldOverWriteExistingCache() {
        let sut = buildSut()
        let existingTimestamp = Date()
        let existingLocalCatalog = createCatalog(1).toLocal()
        let newTimeStamp: Date = existingTimestamp.addingTimeInterval(10)
        let newLocalCatalog = createCatalog(2).toLocal()
        
        assertThatInsertResult(with: (catalog: existingLocalCatalog, timestamp: existingTimestamp), sut).isNil()
        
        assertThatInsertResult(with: (catalog: newLocalCatalog, timestamp: newTimeStamp), sut).isNil()
        assertThatRetrieveResult(sut).isEqual(to: .found(catalog: newLocalCatalog, timestamp: newTimeStamp))
    }
    
    func test_GIVEN_invalidStoreURL_WHEN_insertFails_THEN_shouldDeliverInsertError() {
        let invalidStoreURL = URL(fileURLWithPath: "invalid://path")
        let sut = buildSut(storeURL: invalidStoreURL)
        let timestamp = Date()
        let localCatalog = createCatalog().toLocal()
        
        assertThatInsertResult(with: (catalog: localCatalog, timestamp: timestamp), sut).isNotNil()
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
    
    func buildSut(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableCatalogStorage {
        let sut = CodableCatalogStorage(storageURL: storeURL ?? testStorageURL())
        trackMemoryLeaks(instanceOf: sut, file: file, line: line)
        return sut
    }
    
    private func clearStorage() {
        try? FileManager.default.removeItem(at: testStorageURL())
    }
    
    private func testStorageURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    func assertThatRetrieveResult(
        _ sut: CodableCatalogStorage
    ) -> CatalogStoreResult? {
        let expectation = XCTestExpectation(description: "Waiting for retrieve completion")
        
        var receivedResult: CatalogStoreResult?
        sut.retrieve { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return receivedResult
    }
    
    func assertThatInsertResult(
        with expected: (catalog:LocalCatalog, timestamp: Date),
        _ sut: CodableCatalogStorage
    ) -> Error? {
        let expectation = XCTestExpectation(description: "Waiting for retrieve completion")
        
        var receivedError: Error?
        sut.insert(catalog: expected.catalog, timestamp: expected.timestamp) { error in
            receivedError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return receivedError
    }
}

extension CatalogStoreResult? {
    
    func isEqual(to expected: CatalogStoreResult?, file: StaticString = #filePath, line: UInt = #line) {
        switch (self, expected) {
        case (.empty, .empty):
            break
            
        case let (.found(actualCatalog, actualTimestamp), .found(expectedCatalog, expectedTimestamp)):
            XCTAssertEqual(actualCatalog, expectedCatalog, file: file, line: line)
            XCTAssertEqual(actualTimestamp, expectedTimestamp, file: file, line: line)
            
        case let (.failure(actualError), .failure(expectedError)):
              if let actualNSError = actualError as NSError?, let expectedNSError = expectedError as NSError? {
                  XCTAssertEqual(actualNSError.domain, expectedNSError.domain, file: file, line: line)
                  XCTAssertEqual(actualNSError.code, expectedNSError.code, file: file, line: line)
              } else if let actualDecodingError = actualError as? DecodingError, let expectedDecodingError = expectedError as? DecodingError {
                  XCTAssertEqual(actualDecodingError.localizedDescription, expectedDecodingError.localizedDescription, file: file, line: line)
              } else {
                  XCTFail("Errors are of different types or are not comparable", file: file, line: line)
              }
            
        default:
            XCTFail("Expected result \(String(describing: expected)) but got \(String(describing: self)) instead", file: file, line: line)
        }
    }
    
    func isNotNil(file: StaticString = #filePath, line: UInt = #line) {
        if case .failure(let error) = self {
            XCTAssertNotNil(error, file: file, line: line)
        } else {
            XCTFail("Expected failure but got \(String(describing: self))", file: file, line: line)
        }
    }
}
