//
//  Catalog.swift
//  TMDB
//
//  Created by David Luna on 11/02/25.
//

import Foundation

public struct LocalCatalog: Equatable {
    let page: Int
    let totalPages: Int
    let movies: [LocalMovie]
    
    public init(page: Int, totalPages: Int, movies: [LocalMovie]) {
        self.page = page
        self.totalPages = totalPages
        self.movies = movies
    }
}

public struct LocalMovie: Equatable {
    let id: Int
    let title: String
    let posterPath: String
    
    public init(id: Int, title: String, posterPath: String) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
    }
}

extension Catalog {
    func toLocal() -> LocalCatalog {
        return LocalCatalog(page: page, totalPages: totalPages, movies: movies.toLocal())
    }
}

extension [Movie] {
    func toLocal() -> [LocalMovie] {
        return map {LocalMovie(id: $0.id, title: $0.title, posterPath: $0.posterPath) }
    }
}
