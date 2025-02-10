//
//  RequestBuilderSpy.swift
//  TMDB
//
//  Created by David Luna on 09/02/25.
//

@testable import TMDB

class RequestBuilderSpy: RequestBuilder {
    func build(for endpoint: String, _ httpMethod: HttpMethod) throws -> URLRequest {
        guard let endpoint = validateEndpoint(endpoint) else {
            throw RequestBuilderError.malformedURL
        }
        
        return URLRequest(url: URL(string: "\(anyURL())\(endpoint)")!)
    }
    
    private func validateEndpoint(_ endpoint: String) -> String? {
        let allowedCharacterSet = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "?#"))
        guard !endpoint.isEmpty,
              !endpoint.hasPrefix("/"), !endpoint.hasSuffix("/"),
              endpoint.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil else {
            return nil
        }
        return endpoint
    }
}
