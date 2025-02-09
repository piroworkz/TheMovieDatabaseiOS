//
//  URLSessionHttpClient.swift
//  TMDB
//
//  Created by David Luna on 08/02/25.
//

import Foundation

public class URLSessionHttpClient: HttpClient {
    private let session: URLSession
    private let requestBuilder: RequestBuilder
    
    init (session: URLSession = .shared, requestBuilder: RequestBuilder) {
        self.session = session
        self.requestBuilder = requestBuilder
    }
    
    struct IllegalStateError: Error {}
    
    public func get(from endpoint: String, completion: @escaping (HttpClientResult) -> Void) {
        guard let request = requestBuilder.build(for: endpoint, method: "GET") else {
            completion(.failure(IllegalStateError()))
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(IllegalStateError()))
            }
        }.resume()
    }
}
