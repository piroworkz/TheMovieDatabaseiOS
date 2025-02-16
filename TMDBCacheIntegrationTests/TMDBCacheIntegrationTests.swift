//
//  TMDBCacheIntegrationTests.swift
//  TMDBCacheIntegrationTests
//
//  Created by David Luna on 16/02/25.
//

import XCTest
import TMDB

final class TMDBCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        clearStorage()
    }
    
    override func tearDown() {
        super.tearDown()
        clearStorage()
    }
    
    func test_GIVEN_cacheIsEmpty_WHEN_loadSucceeds_THEN_shouldDeliverEmptyCache() {
        let sut = buildSut()
        
        assertThatLoadResult(from: sut).isEqual(to: .success(emptyCatalog()))
    }
    
    func test_GIVEN_multipleInstancesOfSut_WHEN_loadSucceeds_THEN_shouldDeliverItemsSavedOnDifferentSutInstance() {
        let sutToPerformSave = buildSut()
        let sutToPerformLoad = buildSut()
        let expected = createCatalog()
        
        assertThatSaveResult(expected, from: sutToPerformSave).isNil()
        assertThatLoadResult(from: sutToPerformLoad).isEqual(to: .success(expected))
    }
    
    func test_GIVEN_multipleInstancesOfSut_WHEN_saveSucceeds_THEN_shouldOverWriteExistingCache() {
        let sutForFirstSave = buildSut()
        let sutForSecondSave = buildSut()
        let sutToPerformLoad = buildSut()
        let firstCatalog = createCatalog(1)
        let expectedCatalog = createCatalog(2)
        
        assertThatSaveResult(firstCatalog, from: sutForFirstSave).isNil()
        assertThatSaveResult(expectedCatalog, from: sutForSecondSave).isNil()
        assertThatLoadResult(from: sutToPerformLoad).isEqual(to: .success(expectedCatalog))
    }
    
}
