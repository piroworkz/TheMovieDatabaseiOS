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
    
    func completeInsertSuccessfully(at index: Int = 0) {
        completeDeletionSuccessfully()
        onInsert[index](nil)
    }
}

final class CacheCatalogUseCaseTest: XCTestCase {
    
    func test_GIVEN_sut_WHEN_initialized_THEN_doesNotDeleteCache() {
        let (_, store) = buildSut()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_GIVEN_sut_WHEN_saveIsCalled_THEN_shouldRequestCacheDeletion() {
        let (sut, store) = buildSut()
        
        assertThat(
            given: sut,
            and: store,
            whenever: {})
        .isEqual(to: [.deleteCache])
        
    }
    
    func test_GIVEN_sut_WHEN_deletionFails_THEN_shouldNotRequestCacheInsertion() {
        let (sut, store) = buildSut()
        
        assertThat(
            given: sut,
            and: store,
            whenever: {store.completeDeletion(with: anyNSError())})
        .isEqual(to: [.deleteCache])
    }
    
    func test_GIVEN_sut_WHEN_deletionSucceeds_THEN_shouldRequestTimeStampedCacheInsertion() {
        let timestamp = Date()
        let (sut, store) = buildSut(currentDate: {timestamp})
        
        assertThat(
            given: sut,
            and: store,
            whenever: {store.completeDeletionSuccessfully()})
        .isEqual(to: [.deleteCache, .insert(createCatalog(), timestamp)])
        
        
    }
    
    func test_GIVEN_sut_WHEN_deletionFails_THEN_saveShouldFailAndReturnsError() {
        let expected = anyNSError()
        let (sut, store) = buildSut()
        
        assertThat(
            given: sut,
            whenever: {store.completeDeletion(with: anyNSError())})
        .isEqual(to: expected)
    }
    
    func test_GIVEN_sut_WHEN_insertFails_THEN_saveShouldFailAndReturnsError() {
        let expected = anyNSError()
        let (sut, store) = buildSut()
        
        assertThat(
            given: sut,
            whenever: {
                store.completeDeletionSuccessfully()
                store.completeInsert(with: anyNSError())
            })
        .isEqual(to: expected)
    }
    
    func test_GIVEN_sut_WHEN_insertSucceeds_THEN_shouldReturnNilError() {
        let (sut, store) = buildSut()
        
        assertThat(
            given: sut,
            whenever: { store.completeInsertSuccessfully() })
        .isNil()
    }
    
}

extension Error? {
    func isEqual(to expected: NSError?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self as? NSError, expected, file: file, line: line)
    }
    
    func isNil(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNil(self, file: file, line: line)
    }
}

extension [CatalogStore.ReceivedMessages] {
    func isEqual(to expected: [CatalogStore.ReceivedMessages], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self, expected, file: file, line: line)
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
    
    func assertThat(
        given sut: LocalCatalogLoader,
        whenever action: () -> Void
    ) -> Error? {
        let expectation = expectation(description: expectationDescription())
        
        var receivedError: NSError?
        sut.save(createCatalog()) { error in
            receivedError = error as? NSError
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
        
        return receivedError
    }
    
    func assertThat(
        given sut: LocalCatalogLoader,
        and store: CatalogStore,
        whenever: () -> Void = {}
    ) -> [CatalogStore.ReceivedMessages] {
        
        sut.save(createCatalog()) { _ in }
        whenever()
        
        return store.messages
    }
}
