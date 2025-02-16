//
//  ManagedCatalog.swift
//  TMDB
//
//  Created by David Luna on 15/02/25.
//
import CoreData

@objc(ManagedCatalog)
class ManagedCatalog: NSManagedObject {
    @NSManaged var page: Int64
    @NSManaged var totalPages: Int64
    @NSManaged var movies: NSOrderedSet
    @NSManaged var cache: ManagedCache
    
    var asLocal: LocalCatalog {
        LocalCatalog(page: Int(page), totalPages: Int(totalPages), movies: movies.compactMap { $0 as? ManagedMovie }.map {$0.asLocal} )
    }
    
    static func toManagedCatalog(_ local: LocalCatalog, in context: NSManagedObjectContext) -> ManagedCatalog {
        let managed = ManagedCatalog(context: context)
        managed.page = Int64(local.page)
        managed.totalPages = Int64(local.totalPages)
        
        let managedMovies = local.movies.map { movie -> ManagedMovie in
            let managedMovie = ManagedMovie.toManagedMovie(movie, in: context)
            managedMovie.catalog = managed // 🔹 Asegurar relación correcta
            return managedMovie
        }
        
        managed.movies = NSOrderedSet(array: managedMovies)
        return managed
    }
}
