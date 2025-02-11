//
//  ToLocalMappers.swift
//  TMDB
//
//  Created by David Luna on 11/02/25.
//



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
