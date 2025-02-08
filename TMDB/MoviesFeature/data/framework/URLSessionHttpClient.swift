//
//  URLSessionHttpClient.swift
//  TMDB
//
//  Created by David Luna on 08/02/25.
//

import Foundation

public class URLSessionHttpClient: HttpClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct IllegalStateError: Error {}
    
    public func get(from url: URL, completion: @escaping (HttpClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
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
