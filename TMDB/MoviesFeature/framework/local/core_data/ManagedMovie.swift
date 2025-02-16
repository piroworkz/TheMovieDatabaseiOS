//
//  ManagedMovie.swift
//  TMDB
//
//  Created by David Luna on 15/02/25.
//
import CoreData

@objc(ManagedMovie)
class ManagedMovie: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var title: String
    @NSManaged var posterPath: String
    @NSManaged var catalog: ManagedCatalog
    
    var asLocal: LocalMovie {
        LocalMovie(id: Int(id), title: title, posterPath: posterPath)
    }
    
    static func toManagedMovie(_ local: LocalMovie, in context: NSManagedObjectContext) -> ManagedMovie {
        let managed = ManagedMovie(context: context)
        managed.id = Int64(local.id)
        managed.title = local.title
        managed.posterPath = local.posterPath
        return managed
    }
}
