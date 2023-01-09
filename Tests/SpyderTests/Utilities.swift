import Foundation
import XCTest

extension Data {
  static func safe(from string: String) throws -> Data {
    try XCTUnwrap(string.data(using: .utf8))
  }
}

extension URL {
  static func safe(from string: String) throws -> URL {
    try XCTUnwrap(URL(string: string))
  }
}
