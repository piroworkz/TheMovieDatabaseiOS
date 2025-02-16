//
//  TMDBCatalog.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation


public struct Catalog: Equatable {
    public let page: Int
    public let totalPages: Int
    public let movies: [Movie]
    
    public init(page: Int, totalPages: Int, movies: [Movie]) {
        self.page = page
        self.totalPages = totalPages
        self.movies = movies
    }
}

public struct Movie: Equatable {
    public let id: Int
    public let title: String
    public let posterPath: String
    
    public init(id: Int, title: String, posterPath: String) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
    }
}
