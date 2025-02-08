//
//  URLSessionHttpClientTests.swift
//  TMDBTests
//
//  Created by David Luna on 07/02/25.
//

import XCTest

class URLSessionHttpClient {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

final class URLSessionHttpClientTests: XCTestCase {
    
    func test_GIVEN_sut_WHEN_getIsCalled_THEN_shouldCreateDataTask() {
        let url = URL(string: "https://any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHttpClient(session: session)

        sut.get(from: url)

        XCTAssertEqual(session.receivedURLs, [url])
    }

    class URLSessionSpy: URLSession {
        var receivedURLs: [URL] = []
        private let mockTask = FakeURLSessionDataTask()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return mockTask
        }
        
    }

    class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
}
