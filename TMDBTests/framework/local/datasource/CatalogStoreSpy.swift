//
//  CatalogStoreSpy.swift
//  TMDB
//
//  Created by David Luna on 10/02/25.
//

@testable import TMDB

final class CatalogStoreSpy: CatalogStore {
    
    enum ReceivedMessages :Equatable {
        case deleteCache
        case insert(LocalCatalog, Date)
    }
    
    private var onDelete = [StoreCompletion]()
    private var onInsert = [StoreCompletion]()
    private(set) var messages = [ReceivedMessages]()
    
    func deleteCachedCatalog(completion: @escaping StoreCompletion) {
        onDelete.append(completion)
        messages.append(.deleteCache)
    }
    
    func insert(_ catalog: LocalCatalog, _ timestamp: Date, completion: @escaping StoreCompletion) {
        onInsert.append(completion)
        messages.append(.insert(catalog, timestamp))
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        onDelete[index](error)
    }
    
    func completeInsert(with error: Error, at index: Int = 0) {
        onInsert[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        onDelete[index](nil)
    }
    
    func completeInsertSuccessfully(at index: Int = 0) {
        completeDeletionSuccessfully()
        onInsert[index](nil)
    }
}
