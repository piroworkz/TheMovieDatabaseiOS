//
//  CacheCatalogExtensions.swift
//  TMDB
//
//  Created by David Luna on 10/02/25.
//

import XCTest
import TMDB

extension CacheCatalogUseCaseTest {
    
    func buildSut(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalCatalogLoader, store: CatalogStoreSpy) {
        let store = CatalogStoreSpy()
        let sut = LocalCatalogLoader(store: store, currentDate: currentDate)
        trackMemoryLeaks(instanceOf: store, file: file, line: line)
        trackMemoryLeaks(instanceOf: sut, file: file, line: line)
        return (sut, store)
    }
    
    func createCatalog(_ count: Int = 4) -> Catalog {
        return Catalog(page: 1, totalPages: 0, movies: (0...count).map { self.createMovie(id: $0) })
    }
    
    func createMovie(id: Int) -> Movie {
        return Movie(id: id, title: "Title \(id)", posterPath: "fake poster path \(id)")
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
        and store: CatalogStoreSpy,
        whenever: () -> Void = {}
    ) -> [CatalogStoreSpy.ReceivedMessages] {
        
        sut.save(createCatalog()) { _ in }
        whenever()
        
        return store.messages
    }
}


extension [CatalogStoreSpy.ReceivedMessages] {
    func isEqual(to expected: [CatalogStoreSpy.ReceivedMessages], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self, expected, file: file, line: line)
    }
}


extension LocalCatalogLoader.SaveResult {
    func isEqual(to expected: NSError?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self as? NSError, expected, file: file, line: line)
    }
    
    func isNil(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNil(self, file: file, line: line)
    }
}
