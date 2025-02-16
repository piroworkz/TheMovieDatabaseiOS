//
//  RemoteResultsMapper.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import Foundation

final class RemoteCatalogSerializer {
    private static var successCode: Int { return 200 }
    
    static func decode(_ data: Data, _ statusCode: Int) throws -> RemoteCatalog {
        guard statusCode == successCode, let remoteCatalog = try? JSONDecoder().decode(RemoteCatalog.self, from: data) else {
            throw RemoteCatalogLoader.Error.invalidData
        }
        return remoteCatalog
    }
}
