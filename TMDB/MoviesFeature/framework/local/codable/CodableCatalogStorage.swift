//
//  CodableCatalogStorage.swift
//  TMDB
//
//  Created by David Luna on 14/02/25.
//

import Foundation

public final class CodableCatalogStorage: CatalogStore {
    
    private let storageURL: URL
    private let queue = DispatchQueue(label: "com.davidluna.tmdb.\(CodableCatalogStorage.self).queue", qos: .userInitiated, attributes: .concurrent)
    
    public init(storageURL: URL) {
        self.storageURL = storageURL
    }
    
    public func insert(_ catalog: LocalCatalog, _ timestamp: Date, completion: @escaping StoreCompletion) {
        let storageURL = self.storageURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = CatalogCache(catalog: CodableCatalog(catalog), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storageURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        let storageURL = self.storageURL
        queue.async {
            guard let data = try? Data(contentsOf: storageURL) else {
                return completion(.success(.empty))
            }
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(CatalogCache.self, from: data)
                completion(.success(.found(catalog: cache.localCatalog, timestamp: cache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedCatalog(completion: @escaping StoreCompletion) {
        let storageURL = self.storageURL
        queue.async(flags: .barrier) {
            if !FileManager.default.fileExists(atPath: storageURL.path) {
                completion(nil)
                return
            }
            do {
                try FileManager.default.removeItem(at: storageURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
