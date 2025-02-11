//
//  RequestBuilder.swift
//  TMDB
//
//  Created by David Luna on 08/02/25.
//

import Foundation

public final class URLRequestBuilder: RequestBuilder {
    
    private let baseURL: URL
    private let apiKey: String
    private let apiKeyName: String = "api_key"
    private let acceptName: String = "Accept"
    
    public init(baseURL: String, apiKey: String) throws {
        
        guard let url = URL(string: baseURL) else {
            throw RequestBuilderError.invalidOrMissingBaseURL
        }
        
        guard !apiKey.isEmpty else {
            throw RequestBuilderError.missingApiKey
        }
        self.baseURL = url
        self.apiKey = apiKey
    }
    
    public func build(for endpoint: String, _ httpMethod: HttpMethod) throws -> URLRequest {
        guard let endpoint = validateEndpoint(endpoint),
              let url = configBaseUrl(endpoint: endpoint) else {
            throw RequestBuilderError.malformedURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: acceptName)
        return request
    }
    
    private func configBaseUrl(endpoint: String) -> URL? {
        let url = baseURL.appendingPathComponent(endpoint)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = [
            URLQueryItem(name: apiKeyName, value: apiKey)
        ]
        
        return components.url
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
