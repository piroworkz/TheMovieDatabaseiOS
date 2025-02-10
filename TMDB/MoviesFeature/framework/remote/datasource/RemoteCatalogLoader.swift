//
//  RemoteCatalogLoader.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

public class RemoteCatalogLoader: CatalogLoader {
    private let client: HttpClient
    
    public init(client: HttpClient) {
        self.client = client
    }
    
    public typealias Result = CatalogResult
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func load(from endpoint: String, completion: @escaping (Result) -> Void) {
        client.get(from: endpoint) { [weak self] result in
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
