import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum CachePolicy: Equatable {
  case none
  case inMemory(duration: TimeInterval)
}

public struct CacheManager {
  var policy: CachePolicy
  var entries: [URLRequest: Entry]

  public init(policy: CachePolicy) {
    self.policy = policy
    self.entries = [:]
  }
}

extension CacheManager {
  struct Entry: Equatable {
    let successfulResult: Data
    let expirationDate: Date
  }
}

extension CacheManager {
  public mutating func registerEntryIfNeeded(_ dataEntry: Data, for request: URLRequest, storageDate: Date = .init()) {
    guard case .inMemory(let inMemoryDuration) = policy else {
      return
    }
    let expirationDate = storageDate.addingTimeInterval(inMemoryDuration)
    entries[request] = .init(successfulResult: dataEntry, expirationDate: expirationDate)
  }
}

extension CacheManager {
  mutating func findNonExpiredEntry(for request: URLRequest, comparisonDate: Date = .init()) -> Data? {
    guard policy != .none else {
      return .none
    }
    guard let expectedEntry = entries[request] else {
      return .none
    }
    guard expectedEntry.expirationDate > comparisonDate else {
      entries.removeValue(forKey: request)
      return .none
    }
    return expectedEntry.successfulResult
  }
}
