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
    
    func test_GIVEN_sutAndExpectedError_WHEN_loadFails_THEN_shouldReturnError() {
        let (sut, spy) = buildSut()
        
        assertThat(
            given: sut,
            whenever: { spy.complete(with: NSError(domain: "", code: 0))})
        .isEqual(to: .connectivity)
    }
    
    func test_GIVEN_sutAndExpectedError_WHEN_loadCompletesWithStatusCodeOtherThan200_THEN_shouldReturnInvalidDataError() {
        let testParams = [199, 201, 400, 404, 500]
        let (sut, spy) = buildSut()
        
        testParams.enumerated().forEach {index, code in
            assertThat(
                given: sut,
                whenever: { spy.complete(withCode: code, at: index) })
            .isEqual(to: .invalidData)
        }
    }
    
    func test_GIVEN_sut_WHEN_clientCompletesWithStatusCode200AndInvalidJsonBody_THEN_loadShouldRespondWithInvalidDataError() {
        let (sut, spy) = buildSut()
        
        assertThat(
            given: sut,
            whenever: { spy.complete(withCode: 200, data: Data("Invalid JSON".utf8)) })
        .isEqual(to: .invalidData)
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
        
        func complete(withCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedUrls[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
    
    func buildSut(baseURL: URL = URL(string: "https://example.com")!) -> (sut: RemoteCatalogLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteCatalogLoader(baseURL: baseURL, client: client)
        
        return (sut, client)
    }
    
    private func assertThat(
        given sut: RemoteCatalogLoader,
        whenever action: () -> Void
    ) -> RemoteCatalogLoader.Error? {
        
        var actual: RemoteCatalogLoader.Error?
        sut.load { actual = $0 }
        action()
        
        return actual
    }
}

extension RemoteCatalogLoader.Error? {
    func isEqual(to other: RemoteCatalogLoader.Error?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self, other, file: file, line: line)
    }
}
