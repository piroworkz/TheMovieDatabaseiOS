//
//  ManagedCache.swift
//  TMDB
//
//  Created by David Luna on 15/02/25.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var catalog: ManagedCatalog
    var local: LocalCatalog {
        return catalog.asLocal
    }
}

@objc(ManagedCache)
class ManagedCatalog: NSManagedObject {
    @NSManaged var page: Int64
    @NSManaged var totalPages: Int64
    @NSManaged var movies: NSOrderedSet
    @NSManaged var cache: ManagedCache
    var asLocal: LocalCatalog {
        LocalCatalog(page: Int(page), totalPages: Int(totalPages), movies: movies.compactMap { $0 as? ManagedMovie }.map {$0.asLocal} )
    }
}

@objc(ManagedCache)
class ManagedMovie: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var title: String
    @NSManaged var posterPath: String
    @NSManaged var catalog: ManagedCatalog
    
    var asLocal: LocalMovie {
        LocalMovie(id: Int(id), title: title, posterPath: posterPath)
    }
}
