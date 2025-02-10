//
//  HttpClientResult.swift
//  TMDB
//
//  Created by David Luna on 08/02/25.
//


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