//
//  TMDBTests.swift
//  TMDBTests
//
//  Created by David Luna on 07/02/25.
//

import XCTest
@testable import TMDB

class RemoteCatalogLoader {}

class HttpClient {
    var requestedURL: URL?
}

final class RemoteCatalogLoaderTests: XCTestCase {
    
    
    func test_GIVEN_sut_WHEN_initialized_THEN_shouldNotRequestDataFromAPI() {
        let client = HttpClient()
        let _ = RemoteCatalogLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
}
