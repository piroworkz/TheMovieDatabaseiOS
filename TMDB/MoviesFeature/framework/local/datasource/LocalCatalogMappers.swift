//
//  ToLocalMappers.swift
//  TMDB
//
//  Created by David Luna on 11/02/25.
//

import Foundation

extension Catalog {
    public func toLocal() -> LocalCatalog {
        return LocalCatalog(page: page, totalPages: totalPages, movies: movies.toLocal())
    }
}

extension [Movie] {
    func toLocal() -> [LocalMovie] {
        return map {LocalMovie(id: $0.id, title: $0.title, posterPath: $0.posterPath) }
    }
}


extension LocalCatalog {
    public func toDomain() -> Catalog {
        return Catalog(page: page, totalPages: totalPages, movies: movies.toDomain())
    }
}

extension [LocalMovie] {
    func toDomain() -> [Movie] {
        return map {Movie(id: $0.id, title: $0.title, posterPath: $0.posterPath) }
    }
}

