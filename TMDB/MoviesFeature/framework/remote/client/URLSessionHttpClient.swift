//
//  URLSessionHttpClient.swift
//  TMDB
//
//  Created by David Luna on 08/02/25.
//

import Foundation

public final class URLSessionHttpClient: HttpClient {
    private let session: URLSession
    private let requestBuilder: RequestBuilder
    
    public init (session: URLSession = .shared, requestBuilder: RequestBuilder) {
        self.session = session
        self.requestBuilder = requestBuilder
    }
    
    struct IllegalStateError: Error {}
    struct InvalidRequest: Error {}
    
    public func get(from endpoint: String, completion: @escaping (HttpClient.Result) -> Void) {
        guard let request = try? requestBuilder.build(for: endpoint, .get) else {
            completion(.failure(InvalidRequest()))
            return
        }
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(IllegalStateError()))
            }
        }.resume()
    }
}
