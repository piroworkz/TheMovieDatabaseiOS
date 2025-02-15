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
    
    func assertThat(
        given sut: LocalCatalogLoader,
        whenever action: () -> Void
    ) -> Error? {
        let expectation = expectation(description: expectationDescription())
        
        var receivedError: NSError?
        sut.save(createCatalog()) { error in
            receivedError = error as? NSError
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
        
        return receivedError
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


extension Error? {
    func isEqual(to expected: NSError?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self as? NSError, expected, file: file, line: line)
    }
    
    func isNil(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNil(self, file: file, line: line)
    }
    
    func isNotNil(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNotNil(self, file: file, line: line)
    }
    
    
}
