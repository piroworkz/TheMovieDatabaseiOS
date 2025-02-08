//
//  RemoteCatalogLoader.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

class RemoteCatalogLoader: CatalogLoader {
    private let baseURL: URL
    private let client: HttpClient
    
    init(baseURL: URL, client: HttpClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    public typealias Result = CatalogResult
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    func load(completion: @escaping (Result) -> Void) {
        client.get(from: baseURL) { [weak self] result in
            guard self != nil else { return }
            
            result.fold(
                onSuccess: {data, response in
                    completion(RemoteResultsMapper.map(data, response.statusCode))
                },
                onFailure: { _ in
                    completion(.failure(Error.connectivity))
                })
        }
    }
}
