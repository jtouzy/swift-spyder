@testable import Spyder
import XCTest

final class APITests: XCTestCase {
}

// ========================================================================
// MARK: Test invoker
// ========================================================================

private enum TestInvoker {
  public static let successInvoker: API.Invoker = { request in
    .init(statusCode: 200, headers: [], data: "{\"name\":\"Spyder\"}".data(using: .utf8)!)
  }
  public static let jsonDecodingFailureInvoker: API.Invoker = { request in
    .init(statusCode: 200, headers: [], data: "{}".data(using: .utf8)!)
  }
}

// ========================================================================
// MARK: Test builders
// ========================================================================

private func createSUT(
  invoker: @escaping API.Invoker = TestInvoker.successInvoker,
  headersBuilder: @escaping API.HeadersBuilder = { .init() }
) -> GitHubAPI {
  GitHubAPI.build(
    using: invoker,
    headersBuilder: headersBuilder
  )
}

// ========================================================================
// MARK: Tests
// ========================================================================

extension APITests {
  func test_headers_scenarios() {
    // Given
    let builderHeaders: Set<Header> = .init(
      [.init(name: "spyder-hd-builder", value: "spyder-hd-builder-value")]
    )
    let sut = createSUT(headersBuilder: { builderHeaders })
    // When/Then: Before adding headers
    XCTAssertEqual(sut.allHeaders, builderHeaders)
    // When/Then: After adding headers
    let additionalHeader: Header = .init(name: "spyder-additional-header", value: "spyder-additional-value")
    sut.addHeader(additionalHeader)
    XCTAssertEqual(sut.allHeaders, .init([
      .init(name: "spyder-hd-builder", value: "spyder-hd-builder-value"),
      additionalHeader
    ]))
  }
}

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
