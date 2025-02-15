//
//  ManagedCache.swift
//  TMDB
//
//  Created by David Luna on 15/02/25.
//

import CoreData

private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var catalog: ManagedCatalog
}

private class ManagedCatalog: NSManagedObject {
    @NSManaged var page: Int64
    @NSManaged var totalPages: Int64
    @NSManaged var movies: NSOrderedSet
}

private class ManagedMovie: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var title: String
    @NSManaged var posterPath: String
    @NSManaged var page: Int64
}
