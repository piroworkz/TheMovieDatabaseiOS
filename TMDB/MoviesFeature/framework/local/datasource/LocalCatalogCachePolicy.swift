//
//  LocalCatalogCachePolicy.swift
//  TMDB
//
//  Created by David Luna on 12/02/25.
//

import Foundation

internal final class LocalCatalogCachePolicy {
    
    func validate(_ timestamp: Date, currentDate: Date) -> Bool {
        let daysToExpiration = 7
        guard let maxDate = Calendar.current.date(byAdding: .day, value: daysToExpiration, to: timestamp) else {
            return false
        }
        return currentDate < maxDate
    }
    
}
