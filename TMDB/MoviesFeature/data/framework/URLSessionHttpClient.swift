//
//  URLSessionHttpClient.swift
//  TMDB
//
//  Created by David Luna on 08/02/25.
//

import Foundation

public class URLSessionHttpClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct IllegalStateError: Error {}
    
    public func get(from url: URL, completion: @escaping (HttpClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(IllegalStateError()))
            }
        }.resume()
    }
}
