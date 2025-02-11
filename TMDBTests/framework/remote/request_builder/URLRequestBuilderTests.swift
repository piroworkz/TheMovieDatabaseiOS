//
//  URLRequestBuilderTests.swift
//  TMDB
//
//  Created by David Luna on 09/02/25.
//


import XCTest
import TMDB

class URLRequestBuilderTests: XCTestCase {
    
    func test_GIVEN_invalidUrlString_WHEN_sutIsInitialized_THEN_shouldThrowMalformedUrlError() {
        let invalidUrlStrings = ["invalid url string", ""]
        
        invalidUrlStrings.forEach { invalidUrlString in
            do {
                let _ =  try URLRequestBuilder(baseURL: invalidUrlString, apiKey: anyApiKey())}
            catch {
                XCTAssertEqual(error as? RequestBuilderError, RequestBuilderError.invalidOrMissingBaseURL)
            }
        }
    }
    
    func test_GIVEN_emptyApiKey_WHEN_sutIsInitialized_THEN_shouldThrowMissingApiKeyError() {
        let emptyApiKey = ""
        
        do {
            let _ =  try URLRequestBuilder(baseURL: anyBaseUrl(), apiKey: emptyApiKey)}
        catch {
            XCTAssertEqual(error as? RequestBuilderError, RequestBuilderError.missingApiKey)
        }
    }
    
    func test_GIVEN_invalidEndpoint_WHEN_buildIsCalled_THEN_shouldThrowMalformedURLError() {
        let invalidEndpoints = ["", "invalid endpoint", "#", "/movies/popular", "movies/popular/"]
        let sut = buildSut()
        
        invalidEndpoints.forEach {invalidEndpoint in
            do {
                let actual = try sut.build(for: invalidEndpoint, .get)
                XCTFail("Expected to throw an error but didn't. Actual: \(String(describing: actual))")
            } catch {
                print("<-- ERROR \(error) -->")
                XCTAssertEqual(error as? RequestBuilderError, RequestBuilderError.malformedURL)
            }
        }
    }
    
    func test_GIVEN_sut_WHEN_buildIsSuccessfull_THEN_shouldReturnValidUrlRequest() {
        let endpoint = anyEndpoint()
        let expected = "\(anyBaseUrl())/\(endpoint)?api_key=\(anyApiKey())"
        let sut = buildSut()
        
        let actual = try? sut.build(for: endpoint, .get)
        
        XCTAssertNotNil(actual)
        XCTAssertEqual(actual?.httpMethod, getMethod())
        XCTAssertEqual(actual?.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(actual?.url?.absoluteString, expected)
    }
    
    func buildSut(file: StaticString = #filePath, line: UInt = #line) -> RequestBuilder {
        let sut = try! URLRequestBuilder(baseURL: anyBaseUrl(), apiKey: anyApiKey())
        trackMemoryLeaks(instanceOf: sut, file: file, line: line)
        return sut
    }
}
