//
//  HttpClient.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

protocol HttpClient {
    func get(from url: URL, completion: @escaping (HttpClientResult) -> Void)
}

enum HttpClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}

extension HttpClientResult {
    func fold<T>(
        onSuccess: (HTTPURLResponse) -> T,
        onFailure: (Error) -> T
    ) -> T {
        switch self {
        case .success(let response):
            return onSuccess(response)
        case .failure(let error):
            return onFailure(error)
        }
    }
}
