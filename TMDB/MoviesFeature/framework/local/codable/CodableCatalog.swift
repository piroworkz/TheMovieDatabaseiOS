//
//  CodableCatalog.swift
//  TMDB
//
//  Created by David Luna on 14/02/25.
//

import Foundation

struct CodableCatalog: Codable {
    let page: Int
    let totalPages: Int
    let movies: [CodableMovie]
    
    init(_ catalog: LocalCatalog) {
        page = catalog.page
        totalPages = catalog.totalPages
        movies = catalog.movies.map( CodableMovie.init )
    }
}

struct CodableMovie: Codable {
    let id: Int
    let title: String
    let posterPath: String
    
    init(_ movie: LocalMovie) {
        id = movie.id
        title = movie.title
        posterPath = movie.posterPath
    }
    
    var localMovie: LocalMovie {
        return LocalMovie(id: id, title: title, posterPath: posterPath)
    }
}
