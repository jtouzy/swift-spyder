@testable import Spyder
import XCTest

final class APITests: XCTestCase {
}

// ========================================================================
// MARK: Test invoker
// ========================================================================

private enum TestInvoker {
  public static let successInvoker: API.Invoker = { request in
    .init(statusCode: 200, data: "{\"name\":\"Spyder\"}".data(using: .utf8)!)
  }
  public static let jsonDecodingFailureInvoker: API.Invoker = { request in
    .init(statusCode: 200, data: "{}".data(using: .utf8)!)
  }
}

// ========================================================================
// MARK: Test builders
// ========================================================================

private func createSUT(invoker: @escaping API.Invoker = TestInvoker.successInvoker) -> GitHubAPI {
  GitHubAPI.build(using: invoker)
}

// ========================================================================
// MARK: Tests
// ========================================================================

extension APITests {
  func test_invoking_happyPath() async throws {
    // Given
    let sut = createSUT()
    // When
    let result = try await sut.getRepositories(.init())
    // Then
    XCTAssertEqual(result, .init(name: "Spyder"))
  }
  func test_invoking_jsonDecodingFailure() async throws {
    // Given
    let sut = createSUT(invoker: TestInvoker.jsonDecodingFailureInvoker)
    // When
    do {
      let _ = try await sut.getRepositories(.init())
      XCTFail("The invoking should fail because JSON is malformed")
    } catch {
      XCTAssertEqual(error.localizedDescription, "The data couldn’t be read because it is missing.")
    }
  }
}
