//
//  CacheCatalogUseCaseTest.swift
//  TMDBTests
//
//  Created by David Luna on 10/02/25.
//

import XCTest
import TMDB

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
        .isEqual(to: [.deleteCache, .insert(createCatalog().toLocal(), timestamp)])
        
        
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
    
    func test_GIVEN_sut_WHEN_instanceIsDeallocated_THEN_doesNotDeliverDeleteError() {
        let store = CatalogStoreSpy()
        var sut: LocalCatalogLoader? = LocalCatalogLoader(store: store, currentDate: Date.init)
        
        var receivedError = [LocalCatalogLoader.SaveResult]()
        sut?.save(createCatalog()) { receivedError.append($0)}
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedError.isEmpty)
    }
    
    func test_GIVEN_sut_WHEN_instanceIsDeallocated_THEN_doesNotDeliverInsertError() {
        let store = CatalogStoreSpy()
        var sut: LocalCatalogLoader? = LocalCatalogLoader(store: store, currentDate: Date.init)
        
        var receivedError = [LocalCatalogLoader.SaveResult]()
        sut?.save(createCatalog()) { receivedError.append($0)}
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsert(with: anyNSError())
        
        XCTAssertTrue(receivedError.isEmpty)
    }
}
