//
//  TMDBCatalog.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation


struct Catalog: Equatable {
    let page: Int
    let totalPages: Int
    let catalog: [Movie]
    
    init(page: Int, totalPages: Int, catalog: [Movie]) {
        self.page = page
        self.totalPages = totalPages
        self.catalog = catalog
    }
}

struct Movie: Equatable {
    let id: Int
    let title: String
    let posterPath: String
}

extension Catalog: Decodable {
    enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case catalog = "results"
    }
}

extension Movie: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
    }
}
