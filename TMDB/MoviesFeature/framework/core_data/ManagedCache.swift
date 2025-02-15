//
//  ManagedCache.swift
//  TMDB
//
//  Created by David Luna on 15/02/25.
//

import CoreData

class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged fileprivate var catalog: ManagedCatalog
}

private class ManagedCatalog: NSManagedObject {
    @NSManaged var page: Int64
    @NSManaged var totalPages: Int64
    @NSManaged var movies: NSOrderedSet
    
    @NSManaged var cache: ManagedCache?
}

private class ManagedMovie: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var title: String
    @NSManaged var posterPath: String
    @NSManaged var page: Int64
}
