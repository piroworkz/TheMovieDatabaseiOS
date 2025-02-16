//
//  FetchMoviesUseCase.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

public enum CatalogResult {
    case success(Catalog)
    case failure(Error)
}

public protocol FetchCatalogUseCase {
    func load(from endpoint: String, completion: @escaping (CatalogResult) -> Void)
}

public protocol GetCatalogCaheUseCase {
    func load(completion: @escaping (CatalogResult) -> Void)
}
