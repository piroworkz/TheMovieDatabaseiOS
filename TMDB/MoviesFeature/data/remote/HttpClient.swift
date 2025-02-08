//
//  HttpClient.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

protocol HttpClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}
