@testable import Spyder
import XCTest

final class CacheManagerTests: XCTestCase {
}

// ========================================================================
// MARK: Test builders
// ========================================================================

private func createSUT(policy: CachePolicy) -> CacheManager {
  .init(policy: policy)
}

// ========================================================================
// MARK: Tests
// ========================================================================

extension CacheManagerTests {
  func test_registerEntry_withNoCachePolicy() throws {
    // Given
    let request: URLRequest = .init(url: try .safe(from: "https://www.google.fr"))
    let successfulData: Data = try .safe(from: "{}")
    var sut = createSUT(policy: .none)
    // When
    sut.registerEntryIfNeeded(successfulData, for: request)
    // Then
    XCTAssertEqual(sut.entries, [:])
  }
  func test_registerEntry_withCachePolicy() throws {
    // Given
    let request: URLRequest = .init(url: try .safe(from: "https://www.google.fr"))
    let successfulData: Data = try .safe(from: "{}")
    let cacheDuration: TimeInterval = 30
    var sut = createSUT(policy: .inMemory(duration: cacheDuration))
    // When
    let storageDate = Date()
    sut.registerEntryIfNeeded(successfulData, for: request, storageDate: storageDate)
    // Then
    XCTAssertEqual(sut.entries, [
      request: .init(successfulResult: successfulData, expirationDate: storageDate.addingTimeInterval(cacheDuration))
    ])
  }
}

extension CacheManagerTests {
  func test_findNonExpiredEntry_withNoCachePolicy() throws {
    // Given
    let request: URLRequest = .init(url: try .safe(from: "https://www.google.fr"))
    var sut = createSUT(policy: .none)
    // When
    let result = sut.findNonExpiredEntry(for: request)
    // Then
    XCTAssertNil(result)
  }
  func test_findNonExpiredEntry_withNonExistingCacheEntry() throws {
    // Given
    let request: URLRequest = .init(url: try .safe(from: "https://www.google.fr"))
    var sut = createSUT(policy: .inMemory(duration: 20))
    // When
    let result = sut.findNonExpiredEntry(for: request)
    // Then
    XCTAssertNil(result)
  }
  func test_findNonExpiredEntry_withNonExpiredCacheEntry() throws {
    // Given
    let request: URLRequest = .init(url: try .safe(from: "https://www.google.fr"))
    let successfulData: Data = try .safe(from: "{}")
    let baseStorageDate = Date()
    var sut = createSUT(policy: .inMemory(duration: 30))
    sut.registerEntryIfNeeded(successfulData, for: request, storageDate: baseStorageDate)
    // When
    let result = sut.findNonExpiredEntry(for: request, comparisonDate: baseStorageDate.addingTimeInterval(20))
    // Then
    XCTAssertEqual(result, successfulData)
  }
  func test_findNonExpiredEntry_withExpiredCacheEntry() throws {
    // Given
    let request: URLRequest = .init(url: try .safe(from: "https://www.google.fr"))
    let successfulData: Data = try .safe(from: "{}")
    let baseStorageDate = Date()
    var sut = createSUT(policy: .inMemory(duration: 10))
    sut.registerEntryIfNeeded(successfulData, for: request, storageDate: baseStorageDate)
    // When
    let result = sut.findNonExpiredEntry(for: request, comparisonDate: baseStorageDate.addingTimeInterval(20))
    // Then
    XCTAssertNil(result)
    XCTAssertEqual(sut.entries, [:])
  }
}
