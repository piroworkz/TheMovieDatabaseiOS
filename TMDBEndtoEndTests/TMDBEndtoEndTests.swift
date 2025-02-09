//
//  TMDBEndtoEndTests.swift
//  TMDBEndtoEndTests
//
//  Created by David Luna on 08/02/25.
//

import XCTest
@testable import TMDB

final class TMDBEndtoEndTests: XCTestCase {
    
    
    func test_GIVEN_sut_WHEN_loadUseCaseIsExecuted_THEN_shouldReturnCatalogOfPopularMoviesFromAPI() {
        let sut = buildSut()
        let expectation = expectation(description: "wait for items download to complete")
        
        var catalogResult: CatalogResult?
        sut.load(from: "movie/popular") { result in
            catalogResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        switch catalogResult {
        case let .success(response)?:
            XCTAssertTrue(response.catalog.isEmpty == false)
        case let .failure(error)?:
            XCTFail("Unexpected error: \(error)")
        default:
            XCTFail("Unexpected error")
        }
    }
    
    private func buildSut() -> CatalogLoader {
        guard let apiKey = ProcessInfo.processInfo.environment["apiKey"], !apiKey.isEmpty,
              let baseUrlString = ProcessInfo.processInfo.environment["baseUrlString"], !baseUrlString.isEmpty else {
            fatalError("Missing required environment variables: apiKey and/or baseUrlString")
        }
        let requestBuilder = URLRequestBuilder(baseURL: baseUrlString, apiKey: apiKey)
        let client = URLSessionHttpClient(requestBuilder: requestBuilder)
        let dataSource = RemoteCatalogLoader(client: client)
        return dataSource
    }
}
