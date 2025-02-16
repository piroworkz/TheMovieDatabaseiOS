//
//  RemoteCatalogLoader.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

public class RemoteCatalogLoader: FetchCatalogUseCase {
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
            
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success(data, response):
                do {
                    let catalog = try RemoteCatalogSerializer.decode(data, response.statusCode)
                    completion(.success(catalog.toDomain()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
