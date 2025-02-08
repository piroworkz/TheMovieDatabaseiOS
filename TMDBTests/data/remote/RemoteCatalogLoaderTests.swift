//
//  TMDBTests.swift
//  TMDBTests
//
//  Created by David Luna on 07/02/25.
//

import XCTest
@testable import TMDB

final class RemoteCatalogLoaderTests: XCTestCase {
    
    func test_GIVEN_sut_WHEN_initialized_THEN_shouldNotRequestDataFromAPI() {
        let (_, spy) = buildSut()
        
        let actual = spy.requestedUrls
        
        XCTAssertTrue(actual.isEmpty)
    }
    
    func test_GIVEN_sutIsInitialized_WHEN_loadIsCalled_THEN_shouldMakeRequestToProvidedUrl() {
        let expected = [URL(string: "https://example.com")!]
        let (sut, spy) = buildSut()
        
        sut.load() { _ in }
        let actual = spy.requestedUrls
        
        XCTAssertEqual(actual, expected)
    }
    
    func test_GIVEN_sutAndExpectedURLsArray_WHEN_loadIsCalledTwice_THEN_shouldMakeRequestToProvidedUrlTwice() {
        let (sut, spy) = buildSut()
        let url = URL(string: "https://example.com")!
        let expected = [url, url]
        
        sut.load() { _ in }
        sut.load() { _ in }
        let actual = spy.requestedUrls
        
        XCTAssertEqual(actual, expected)
    }
    
    func test_GIVEN_sut_WHEN_clientCompletesWithError_THEN_loadShouldReturnConnectivityError() {
        let (sut, spy) = buildSut()
        
        assertThat(
            given: sut,
            whenever: { spy.complete(with: NSError(domain: "", code: 0))})
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
        var sut: RemoteCatalogLoader? = RemoteCatalogLoader(baseURL: URL(string: "https://example.com")!, client: client)
        let emptyListJsonData = jsonResult(size: 0)
        
        var results = [RemoteCatalogLoader.Result]()
        sut?.load { results.append($0) }
        
        sut = nil
        client.complete(withCode: 200, data: emptyListJsonData)
        
        XCTAssertTrue(results.isEmpty)
    }
}

extension RemoteCatalogLoaderTests {
    
    class HttpClientSpy: HttpClient {
        
        var requestedUrls: [URL] { return messages.map { $0.url } }
        private var messages = [(url: URL, completion: (HttpClientResult) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HttpClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedUrls[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
    
    func buildSut(baseURL: URL = URL(string: "https://example.com")!) -> (sut: RemoteCatalogLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteCatalogLoader(baseURL: baseURL, client: client)
        trackMemoryLeaks(instanceOf: client)
        trackMemoryLeaks(instanceOf: sut)
        return (sut, client)
    }
    
    private func assertThat(
        given sut: RemoteCatalogLoader,
        whenever action: () -> Void
    ) -> RemoteCatalogLoader.Result? {
        let expectation = expectation(description: "Wait for completion result")
        
        var result: RemoteCatalogLoader.Result?
        sut.load {
            result = $0
            expectation.fulfill()
        }
        action()
        
        wait(for: [expectation], timeout: 1.0)
        return result
    }
    
    private func jsonResult(size count: Int = 3) -> Data {
        let movies: [[String: Any]] = count > 0 ? (0..<count).map { mapMovie($0) } : []
        let jsonBody: [String: Any] = [
            "page": count / 3,
            "total_pages": count / 3,
            "results": movies
        ]
        
        return try! JSONSerialization.data(withJSONObject: jsonBody)
    }
    
    private func mapMovie(_ index: Int) -> [String : Any] {
        return [
            "id": index,
            "title": "title \(index)",
            "poster_path": "posterPath \(index)"
        ]
    }
    
    private func decode(_ data: Data) -> RemoteCatalogLoader.Result {
        return RemoteResultsMapper.map(data, 200)
    }
}

extension RemoteCatalogLoader.Result? {
    func isEqual(to expected: RemoteCatalogLoader.Result?, file: StaticString = #filePath, line: UInt = #line) {
        switch (self, expected) {
        case let (.success(actualResult), .success(expectedResult)):
            XCTAssertEqual(actualResult, expectedResult, file: file, line: line)
        case let (.failure(actualResult as RemoteCatalogLoader.Error), .failure(expectedResult as RemoteCatalogLoader.Error)):
            XCTAssertEqual(actualResult, expectedResult, file: file, line: line)
        default :
            XCTFail("Expected result \(String(describing: expected)) but got \(String(describing: self)) instead", file: file, line: line)
        }
    }
}

extension XCTestCase {
    func trackMemoryLeaks(instanceOf object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Instance should be nil after tear down, Potential memory leak", file: file, line: line)
        }
    }
}
