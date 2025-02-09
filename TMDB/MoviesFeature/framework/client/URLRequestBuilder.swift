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
        guard let url = configBaseUrl(endpoint: endpoint), endpoint.isEmpty == false else {return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: acceptName)
        return request
    }
    
    private func configBaseUrl(endpoint: String) -> URL? {
        guard let baseUrl = URL(string: baseURL) else { return nil }
        let fullUrl = baseUrl.appendingPathComponent(endpoint)
        guard var components = URLComponents(url: fullUrl, resolvingAgainstBaseURL: false) else { return nil }
        components.queryItems = [
            URLQueryItem(name: apiKeyName, value: apiKey)
        ]
        return components.url
    }
    
}
