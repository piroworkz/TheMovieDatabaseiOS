//
//  CatalogStoreSpy.swift
//  TMDB
//
//  Created by David Luna on 10/02/25.
//

import TMDB

final class CatalogStoreSpy: CatalogStore {
    
    enum ReceivedMessages :Equatable {
        case deleteCache
        case insert(LocalCatalog, Date)
        case retrieve
    }
    
    private var onDelete = [StoreCompletion]()
    private var onInsert = [StoreCompletion]()
    private var onRetrieve = [RetrieveCompletion]()
    private(set) var messages = [ReceivedMessages]()
    
    func deleteCachedCatalog(completion: @escaping StoreCompletion) {
        onDelete.append(completion)
        messages.append(.deleteCache)
    }
    
    func insert(_ catalog: LocalCatalog, _ timestamp: Date, completion: @escaping StoreCompletion) {
        onInsert.append(completion)
        messages.append(.insert(catalog, timestamp))
    }
    
    func retrieve(completion: @escaping RetrieveCompletion) {
        print("<-- retrieve")
        onRetrieve.append(completion)
        print("<-- onRetrieve count \(onRetrieve.count)")
        messages.append(.retrieve)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        onDelete[index](.failure(error))
    }
    
    func completeInsert(with error: Error, at index: Int = 0) {
        onInsert[index](.failure(error))
    }
        
    func completeRetrieve(with error: Error, at index: Int = 0) {
        onRetrieve[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        onDelete[index](.success(()))
    }
    
    func completeInsertSuccessfully(at index: Int = 0) {
        completeDeletionSuccessfully()
        onInsert[index](.success(()))
    }
    
    func completeRetrieveSuccessfully(at index: Int = 0) {
        onRetrieve[index](.success(.none))
    }
    
    func completeRetrieveSuccessfully(with catalog: LocalCatalog,_ timestamp: Date, at index: Int = 0) {
        let result = CatalogStoreResult.success(Cache(catalog, timestamp))
        onRetrieve[index](result)
    }
    
}
