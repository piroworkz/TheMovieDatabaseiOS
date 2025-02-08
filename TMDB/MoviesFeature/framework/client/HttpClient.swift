//
//  HttpClient.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

public protocol HttpClient {
    func get(from endpoint: String, completion: @escaping (HttpClientResult) -> Void)
}
