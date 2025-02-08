//
//  FetchMoviesUseCase.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

enum CatalogResult<Error: Swift.Error> {
    case success(Catalog)
    case failure(Error)
}

protocol CatalogLoader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (CatalogResult<Error>) -> Void)
}
