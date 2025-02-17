//
//  CacheCatalogExtensions.swift
//  TMDB
//
//  Created by David Luna on 10/02/25.
//

import XCTest
import TMDB

protocol XCTStoreTestCase {}

extension XCTStoreTestCase where Self: XCTestCase {
    
    func buildSut(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalCatalogLoader, store: CatalogStoreSpy) {
        let store = CatalogStoreSpy()
        let sut = LocalCatalogLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(instanceOf: store, file: file, line: line)
        trackMemoryLeaks(instanceOf: sut, file: file, line: line)
        return (sut, store)
    }
    
    func assertThatSaveResult(
        given sut: LocalCatalogLoader,
        whenever action: () -> Void
    ) -> LocalCatalogLoader.SaveResult? {
        let expectation = expectation(description: expectationDescription())
        
        var receivedResult: LocalCatalogLoader.SaveResult?
        sut.save(createCatalog()) { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
        
        return receivedResult
    }
  
    func assertThat(
        given sut: LocalCatalogLoader,
        whenever action: () -> Void
    ) -> LocalCatalogLoader.LoadResult? {
        let expectation = expectation(description: expectationDescription())
        
        var receivedResult:  LocalCatalogLoader.LoadResult?
        sut.load { result in
            receivedResult = result
            expectation.fulfill()
        }
        action()
        
        wait(for: [expectation], timeout: 1.0)
        
        return receivedResult
    }
  
    func assertThat(
        given sut: LocalCatalogLoader,
        and store: CatalogStoreSpy,
        whenever: () -> Void = {}
    ) -> [CatalogStoreSpy.ReceivedMessages] {
        
        sut.save(createCatalog()) { _ in }
        whenever()
        
        return store.messages
    }
    
    func expirationDate(adding seconds: TimeInterval? = nil, from now: Date) -> Date {
        let daysToExpiration = 7
        var date = Calendar.current.date(byAdding: .day, value: -daysToExpiration, to: now)!
        guard let seconds else { return date }
        date.addTimeInterval(seconds)
        return date
    }
    
}


extension [CatalogStoreSpy.ReceivedMessages] {
    func isEqual(to expected: [CatalogStoreSpy.ReceivedMessages], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self, expected, file: file, line: line)
    }
}
