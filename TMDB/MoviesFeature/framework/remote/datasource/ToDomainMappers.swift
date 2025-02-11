//
//  ToDomainMappers.swift
//  TMDB
//
//  Created by David Luna on 11/02/25.
//


extension RemoteCatalog {
    func toDomain() -> Catalog {
        return Catalog(page: page, totalPages: total_pages, movies: results.toDomain())
    }
}

extension [RemoteMovie] {
    func toDomain() -> [Movie] {
        return map {Movie(id: $0.id, title: $0.title, posterPath: $0.poster_path) }
    }
}
