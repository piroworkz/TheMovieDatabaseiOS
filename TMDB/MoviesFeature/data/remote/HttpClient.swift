//
//  HttpClient.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

public protocol HttpClient {
    func get(from url: URL, completion: @escaping (HttpClientResult) -> Void)
}

public enum HttpClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

extension HttpClientResult {
    func fold<T>(
        onSuccess: (Data, HTTPURLResponse) -> T,
        onFailure: (Error) -> T
    ) -> T {
        switch self {
        case .success(let data, let response):
            return onSuccess(data, response)
        case .failure(let error):
            return onFailure(error)
        }
    }
}
