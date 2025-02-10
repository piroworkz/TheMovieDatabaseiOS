//
//  CacheCatalogUseCaseTest.swift
//  TMDBTests
//
//  Created by David Luna on 10/02/25.
//

import XCTest
import TMDB

class LocalCatalogLoader {
    
    private let store: CatalogStore
    private let currentDate: () -> Date
    
    init(store: CatalogStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ catalog: Catalog, completion: @escaping (Error?) -> Void) {
        store.deleteCachedCatalog { [unowned self] error in
            if error == nil {
                store.insert(catalog, currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}


class CatalogStore {
    typealias NullableErrorCompletion = (Error?) -> Void
    
    enum ReceivedMessages :Equatable {
        case deleteCache
        case insert(Catalog, Date)
    }
    
    private var onDelete = [NullableErrorCompletion]()
    private var onInsert = [NullableErrorCompletion]()
    private(set) var messages = [ReceivedMessages]()
    
    func deleteCachedCatalog(completion: @escaping NullableErrorCompletion) {
        onDelete.append(completion)
        messages.append(.deleteCache)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        onDelete[index](error)
    }
    
    func completeInsert(with error: Error, at index: Int = 0) {
        onInsert[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        onDelete[index](nil)
    }
    
    func insert(_ catalog: Catalog, _ timestamp: Date, completion: @escaping NullableErrorCompletion) {
        onInsert.append(completion)
        messages.append(.insert(catalog, timestamp))
    }
    
}

final class CacheCatalogUseCaseTest: XCTestCase {
    
    func test_GIVEN_sut_WHEN_initialized_THEN_doesNotDeleteCache() {
        let (_, store) = buildSut()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_GIVEN_sut_WHEN_saveIsCalled_THEN_shouldRequestCacheDeletion() {
        let (sut, store) = buildSut()
        let catalog = createCatalog()
        
        sut.save(catalog) { _ in }
        
        XCTAssertEqual(store.messages, [.deleteCache])
    }
    
    func test_GIVEN_sut_WHEN_deletionFails_THEN_shouldNotRequestCacheInsertion() {
        let (sut, store) = buildSut()
        let catalog = createCatalog()
        
        sut.save(catalog) { _ in }
        store.completeDeletion(with: anyNSError())
        
        XCTAssertEqual(store.messages, [.deleteCache])
    }
    
    func test_GIVEN_sut_WHEN_deletionSucceeds_THEN_shouldRequestTimeStampedCacheInsertion() {
        let timestamp = Date()
        let catalog = createCatalog()
        let (sut, store) = buildSut(currentDate: {timestamp})
        
        sut.save(catalog) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.messages, [.deleteCache, .insert(catalog, timestamp)])
    }
    
    func test_GIVEN_sut_WHEN_deletionFails_THEN_saveShouldFailAndReturnsError() {
        let expected = anyNSError()
        let catalog = createCatalog()
        let (sut, store) = buildSut()
        let expectation = expectation(description: expectationDescription())
        
        var receivedError: NSError?
        sut.save(catalog) { error in
            receivedError = error as? NSError
            expectation.fulfill()
        }
        store.completeDeletion(with: anyNSError())
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(receivedError, expected)
    }
    
    
    func test_GIVEN_sut_WHEN_insertFails_THEN_saveShouldFailAndReturnsError() {
        let expected = anyNSError()
        let catalog = createCatalog()
        let (sut, store) = buildSut()
        let expectation = expectation(description: expectationDescription())
        
        var receivedError: NSError?
        sut.save(catalog) { error in
            receivedError = error as? NSError
            expectation.fulfill()
        }
        store.completeDeletionSuccessfully()
        store.completeInsert(with: anyNSError())
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(receivedError, expected)
    }
    
    
}

extension CacheCatalogUseCaseTest {
    
    func buildSut(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalCatalogLoader, store: CatalogStore) {
        let store = CatalogStore()
        let sut = LocalCatalogLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(instanceOf: store, file: file, line: line)
        trackMemoryLeaks(instanceOf: sut, file: file, line: line)
        return (sut, store)
    }
    
    func createCatalog(_ count: Int = 4) -> Catalog {
        return Catalog(page: 1, totalPages: 0, catalog: (0...count).map { self.createMovie(id: $0) })
    }
    
    
    func createMovie(id: Int) -> Movie {
        return Movie(id: id, title: "Title \(id)", posterPath: "fake poster path \(id)")
    }
}
