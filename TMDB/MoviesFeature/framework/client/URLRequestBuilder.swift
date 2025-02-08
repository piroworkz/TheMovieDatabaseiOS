//
//  RequestBuilder.swift
//  TMDB
//
//  Created by David Luna on 08/02/25.
//

protocol RequestBuilder {
    func build(for endpoint: String, method: String) -> URLRequest?
}

class URLRequestBuilder: RequestBuilder {
    
    private let baseURL: String
    private let apiKey: String
    private let apiKeyName: String = "api_key"
    private let acceptName: String = "Accept"
    
    init(baseURL: String, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
    
    func build(for endpoint: String, method: String) -> URLRequest? {
        guard let finalUrl = configBaseUrl(endpoint: endpoint) else {return nil }
        var request = URLRequest(url: finalUrl)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: acceptName)
        return request
    }
    
    private func configBaseUrl(endpoint: String) -> URL? {
        var components = URLComponents()
        components.path = endpoint
        components.queryItems = [
            URLQueryItem(name: apiKeyName, value: apiKey)
        ]
        let urlComponents = components
        guard let finalUrl = urlComponents.url(relativeTo: createURL()) else { return nil }
        
        return finalUrl
    }
    
    private func createURL() -> URL? {
        let url = URL(string: baseURL)
        return url
    }
    
}
