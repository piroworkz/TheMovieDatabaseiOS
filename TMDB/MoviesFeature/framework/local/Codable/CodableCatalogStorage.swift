//
//  CodableCatalogStorage.swift
//  TMDB
//
//  Created by David Luna on 14/02/25.
//



class CodableCatalogStorage: CatalogStore {
    
    private let storageURL: URL
    
    init(storageURL: URL) {
        self.storageURL = storageURL
    }
    
    func insert(_ catalog: LocalCatalog, _ timestamp: Date, completion: @escaping StoreCompletion) {
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
    
    func retrieve(completion: @escaping RetrieveCompletion) {
        guard let data = try? Data(contentsOf: storageURL) else {
            return completion(.empty)
        }
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(CatalogCache.self, from: data)
            completion(.found(catalog: cache.localCatalog, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
        
    }
    
    func deleteCachedCatalog(completion: @escaping StoreCompletion) {
        
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
