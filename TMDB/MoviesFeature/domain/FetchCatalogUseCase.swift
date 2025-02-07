//
//  FetchMoviesUseCase.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

enum CatalogResult {
    case success(Catalog)
    case failure(Error)
}

protocol CatalogLoader {
    func load(completion: @escaping (CatalogResult) -> Void)
}
