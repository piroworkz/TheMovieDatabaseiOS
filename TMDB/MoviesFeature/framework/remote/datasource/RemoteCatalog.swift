//
//  RemoteCatalog.swift
//  TMDB
//
//  Created by David Luna on 11/02/25.
//

import Foundation

internal struct RemoteCatalog: Decodable {
    let page: Int
    let total_pages: Int
    let results: [RemoteMovie]
}

internal struct RemoteMovie: Decodable {
    let id: Int
    let title: String
    let poster_path: String
}
