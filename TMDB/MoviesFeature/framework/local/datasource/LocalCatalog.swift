//
//  Catalog.swift
//  TMDB
//
//  Created by David Luna on 11/02/25.
//

import Foundation

public struct LocalCatalog: Equatable {
    public let page: Int
    public let totalPages: Int
    public let movies: [LocalMovie]
    
    public init(page: Int, totalPages: Int, movies: [LocalMovie]) {
        self.page = page
        self.totalPages = totalPages
        self.movies = movies
    }
}

public struct LocalMovie: Equatable {
    public let id: Int
    public let title: String
    public let posterPath: String
    
    public init(id: Int, title: String, posterPath: String) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
    }
}
