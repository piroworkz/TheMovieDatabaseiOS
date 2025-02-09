//
//  RequestBuilderSpy.swift
//  TMDB
//
//  Created by David Luna on 09/02/25.
//

@testable import TMDB

class RequestBuilderSpy: RequestBuilder {
    func build(for endpoint: String, method: String) -> URLRequest? {
        return URLRequest(url: URL(string: "\(anyURL())\(endpoint)")!)
    }
}
