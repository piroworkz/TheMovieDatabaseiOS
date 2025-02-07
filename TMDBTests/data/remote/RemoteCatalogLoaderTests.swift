//
//  TMDBTests.swift
//  TMDBTests
//
//  Created by David Luna on 07/02/25.
//

import XCTest
import TMDB

final class RemoteCatalogLoaderTests: XCTestCase {
    
    func test_GIVEN_sut_WHEN_initialized_THEN_shouldNotRequestDataFromAPI() {
        let (_, spy) = buildSut()
        
        let actual = spy.requestedUrls
        
        XCTAssertTrue(actual.isEmpty)
    }
    
    func test_GIVEN_sutIsInitialized_WHEN_loadIsCalled_THEN_shouldMakeRequestToProvidedUrl() {
        let expected = [anyURL()]
        let (sut, spy) = buildSut()
        
        sut.load() { _ in }
        let actual = spy.requestedUrls
        
        XCTAssertEqual(actual, expected)
    }
    
    func test_GIVEN_sutAndExpectedURLsArray_WHEN_loadIsCalledTwice_THEN_shouldMakeRequestToProvidedUrlTwice() {
        let (sut, spy) = buildSut()
        let expected = [anyURL(), anyURL()]
        
        sut.load() { _ in }
        sut.load() { _ in }
        let actual = spy.requestedUrls
        
        XCTAssertEqual(actual, expected)
    }
    
    func test_GIVEN_sut_WHEN_clientCompletesWithError_THEN_loadShouldReturnConnectivityError() {
        let (sut, spy) = buildSut()
        
        assertThat(
            given: sut,
            whenever: { spy.complete(with: anyNSError())})
        .isEqual(to: .failure(RemoteCatalogLoader.Error.connectivity))
    }
    
    func test_GIVEN_sutAndTestParams_WHEN_clientCompletesWithStatusCodeOtherThan200_THEN_loadShouldReturnInvalidDataError() {
        let testParams = [199, 201, 400, 404, 500]
        let (sut, spy) = buildSut()
        
        testParams.enumerated().forEach {index, code in
            assertThat(
                given: sut,
                whenever: { spy.complete(withCode: code, data: jsonResult(size: 0), at: index) })
            .isEqual(to: .failure(RemoteCatalogLoader.Error.invalidData))
        }
    }
    
    func test_GIVEN_sut_WHEN_clientCompletesWithStatusCode200AndInvalidJsonBody_THEN_loadShouldRespondWithInvalidDataError() {
        let (sut, spy) = buildSut()
        
        assertThat(
            given: sut,
            whenever: { spy.complete(withCode: 200, data: Data("Invalid JSON".utf8)) })
        .isEqual(to: .failure(RemoteCatalogLoader.Error.invalidData))
    }
    
    func test_GIVEN_sut_WHEN_clientCompletesWithStatusCode200AndEmptyJsonBody_THEN_loadShouldRespondWithSuccessEmptyResult() {
        let (sut, spy) = buildSut()
        let emptyListJsonData = jsonResult(size: 0)
        
        assertThat(
            given: sut,
            whenever: {spy.complete(withCode: 200, data: emptyListJsonData)})
        .isEqual(to: decode(emptyListJsonData))
    }
    
    func test_GIVEN_sut_WHEN_clientCompletesWithStatusCode200AndValidJsonBody_THEN_loadShouldRespondWithSuccessResult() {
        let (sut, spy) = buildSut()
        let successResult = jsonResult()
        
        assertThat(
            given: sut,
            whenever: {spy.complete(withCode: 200, data: successResult)})
        .isEqual(to: decode(successResult))
    }
    
    func test_GIVEN_sut_WHEN_sutHasBeenDeallocated_THEN_shouldNotDeliverResult() {
        let client = HttpClientSpy()
        var sut: RemoteCatalogLoader? = RemoteCatalogLoader(baseURL: anyURL(), client: client)
        let emptyListJsonData = jsonResult(size: 0)
        
        var results = [RemoteCatalogLoader.Result]()
        sut?.load { results.append($0) }
        
        sut = nil
        client.complete(withCode: 200, data: emptyListJsonData)
        
        XCTAssertTrue(results.isEmpty)
    }
}
