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
