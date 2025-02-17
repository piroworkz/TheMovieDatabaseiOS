//
//  HttpClient.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

public protocol HttpClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from endpoint: String, completion: @escaping (Result) -> Void)
}
