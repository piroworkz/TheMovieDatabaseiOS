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
}

struct Movie: Equatable {
    let id: Int
    let title: String
    let posterPath: String
}
