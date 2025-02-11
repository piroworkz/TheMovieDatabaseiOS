//
//  RemoteResultsMapper.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

internal final class RemoteCatalogSerializer {
    private static var successCode: Int { return 200 }
    
    internal static func decode(_ data: Data, _ statusCode: Int) throws -> RemoteCatalog {
        guard statusCode == successCode, let remoteCatalog = try? JSONDecoder().decode(RemoteCatalog.self, from: data) else {
            throw RemoteCatalogLoader.Error.invalidData
        }
        return remoteCatalog
    }
}

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
