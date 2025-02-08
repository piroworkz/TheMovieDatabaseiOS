//
//  RemoteResultsMapper.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

class RemoteResultsMapper {
    private static var successCode: Int { return 200 }
    
    public static func map(_ data: Data, _ statusCode: Int) -> RemoteCatalogLoader.Result {
        guard statusCode == successCode, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }
        return .success(root.response)
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
