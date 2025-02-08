//
//  RemoteCatalogLoader.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

class RemoteCatalogLoader {
    private let baseURL: URL
    private let client: HttpClient
    
    init(baseURL: URL, client: HttpClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    enum Result: Equatable {
        case success(Catalog)
        case failure(Error)
    }
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    func load(completion: @escaping (Result) -> Void) {
        client.get(from: baseURL) { result in
            result.fold(
                onSuccess: {data, _ in
                    if let root = try? JSONDecoder().decode(Root.self, from: data) {
                        completion(.success(RemoteCatalogLoader.map(root)))
                    } else {
                        completion(.failure(.invalidData))
                    }
                },
                onFailure: { _ in
                    completion(.failure(.connectivity))
                })
        }
    }
    private static func map(_ root: Root) -> Catalog {
        return Catalog(
            page: root.page,
            totalPages: root.total_pages,
            catalog: root.results
        )
    }
    
}

private struct Root: Decodable {
    let results: [Movie]
    let page: Int
    let total_pages: Int
}
