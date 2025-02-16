//
//  TestCommonFakes.swift
//  TMDBTests
//
//  Created by David Luna on 08/02/25.
//

import XCTest
import TMDB

func anyURL() -> URL {
    return URL(string: "https://example.com")!
}

func anyBaseUrl() -> String {
    return "https://api.themoviedb.org/3"
}

func anyApiKey() -> String {
    return "anyApiKey"
}

func anyEndpoint() -> String {
    return "movie/popular"
}

func getMethod() -> String {
    return "GET"
}

func anyNSError() -> NSError {
    return NSError(domain: "", code: 4, userInfo: nil)
}

func anyHttpUrlResponse() -> HTTPURLResponse {
    return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}

func anyUrlResponse() -> URLResponse {
    return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func expectationDescription(_ description: String = "Wait for request to complete") -> String {
    return description
}

func createCatalog(_ count: Int = 3) -> Catalog {
    let movies = count > 0 ? (0...count).map { createMovie(id: $0) } : []
    return Catalog(page: 0, totalPages: 0, movies: movies)
}

func createMovie(id: Int) -> Movie {
    return Movie(id: id, title: "Title \(id)", posterPath: "fake poster path \(id)")
}

func emptyCatalog() -> Catalog {
    return Catalog(page: 0, totalPages: 0, movies: [])
}
