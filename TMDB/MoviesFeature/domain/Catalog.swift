//
//  TMDBCatalog.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation


public struct Catalog: Equatable {
    let page: Int
    let totalPages: Int
    let movies: [Movie]
    
    public init(page: Int, totalPages: Int, movies: [Movie]) {
        self.page = page
        self.totalPages = totalPages
        self.movies = movies
    }
}

public struct Movie: Equatable {
    let id: Int
    let title: String
    let posterPath: String
    
    public init(id: Int, title: String, posterPath: String) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
    }
}
