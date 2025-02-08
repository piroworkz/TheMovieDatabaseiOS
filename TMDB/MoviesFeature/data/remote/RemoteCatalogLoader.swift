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
                onSuccess: {data, response in
                    if let result = try? RemoteResultsMapper.map(data, response.statusCode) {
                        completion(.success(result))
                    } else {
                        completion(.failure(.invalidData))
                    }
                },
                onFailure: { _ in
                    completion(.failure(.connectivity))
                })
        }
    }
}

class RemoteResultsMapper {
    public static func map(_ data: Data, _ statusCode: Int) throws -> Catalog {
        guard statusCode == 200 else {
            throw RemoteCatalogLoader.Error.invalidData
        }
        
        return try JSONDecoder().decode(Root.self, from: data).response
    }
    
    struct Root: Decodable {
        let results: [Result]
        let page: Int
        let total_pages: Int
        
        var response: Catalog {
            return Catalog(page: page, totalPages: total_pages, catalog: results.map { $0.movie })
        }
        
        struct Result: Decodable {
            let id: Int
            let title: String
            let poster_path: String
            
            var movie: Movie {
                return Movie(id: id, title: title, posterPath: poster_path)
            }
        }
    }
}
