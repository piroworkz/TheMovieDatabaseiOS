//
//  HttpClientSpy.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import XCTest
@testable import TMDB

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
    
    func assertThat(
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
    
    func jsonResult(size count: Int = 3) -> Data {
        let movies: [[String: Any]] = count > 0 ? (0..<count).map { mapMovie($0) } : []
        let jsonBody: [String: Any] = [
            "page": count / 3,
            "total_pages": count / 3,
            "results": movies
        ]
        
        return try! JSONSerialization.data(withJSONObject: jsonBody)
    }
    
    func mapMovie(_ index: Int) -> [String : Any] {
        return [
            "id": index,
            "title": "title \(index)",
            "poster_path": "posterPath \(index)"
        ]
    }
    
    func decode(_ data: Data) -> RemoteCatalogLoader.Result {
        return RemoteResultsMapper.map(data, 200)
    }
}
