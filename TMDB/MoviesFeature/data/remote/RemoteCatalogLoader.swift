//
//  RemoteCatalogLoader.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

class RemoteCatalogLoader {
    private let baseURL: URL
    private let client: HttpClient
    
    init(baseURL: URL, client: HttpClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    func load() {
        client.get(from: baseURL)
    }
}
