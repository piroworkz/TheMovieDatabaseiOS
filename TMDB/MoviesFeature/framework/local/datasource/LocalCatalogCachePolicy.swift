//
//  LocalCatalogCachePolicy.swift
//  TMDB
//
//  Created by David Luna on 12/02/25.
//



private final class LocalCatalogCachePolicy {
    private let currentDate: () -> Date
    
    init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }
    
    func validate(_ timestamp: Date) -> Bool {
        let daysToExpiration = 7
        guard let maxDate = Calendar.current.date(byAdding: .day, value: daysToExpiration, to: timestamp) else {
            return false
        }
        return currentDate() < maxDate
    }
    
}