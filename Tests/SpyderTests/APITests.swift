@testable import Spyder
import XCTest

final class APITests: XCTestCase {
}

// ========================================================================
// MARK: Test invoker
// ========================================================================

private enum TestInvoker {
  public static let successInvoker: API.Invoker = { request in
    .init(statusCode: 200, headers: [], data: try .safe(from: "{\"name\":\"Spyder\"}"))
  }
  public static let jsonDecodingFailureInvoker: API.Invoker = { request in
    .init(statusCode: 200, headers: [], data: try .safe(from: "{}"))
  }
  public static let serverFailureInvoker: API.Invoker = { request in
    .init(statusCode: 500, headers: [], data: try .safe(from: "{}"))
  }
  public static func spy(invoker: @escaping API.Invoker) -> SpyInvoker {
    .init(internalInvoker: invoker)
  }
}
private class SpyInvoker {
  private var internalInvoker: API.Invoker
  var invocationCount: Int = .zero

  init(internalInvoker: @escaping API.Invoker) {
    self.internalInvoker = internalInvoker
  }

  var invoker: API.Invoker {
    return { [weak self] request in
      guard let self = self else {
        enum ReferenceError: Error { case missingSelfReferenceInContext }
        throw ReferenceError.missingSelfReferenceInContext
      }
      self.invocationCount += 1
      return try await self.internalInvoker(request)
    }
  }
}

// ========================================================================
// MARK: Test builders
// ========================================================================

private func createSUT(
  invoker: @escaping API.Invoker = TestInvoker.successInvoker,
  headersBuilder: @escaping API.HeadersBuilder = { .init() },
  cachePolicy: CachePolicy = .none
) -> GitHubAPI {
  GitHubAPI.build(
    using: invoker,
    headersBuilder: headersBuilder,
    cachePolicy: cachePolicy
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
  func test_invoking_serverFailure() async throws {
    // Given
    let sut = createSUT(invoker: TestInvoker.serverFailureInvoker)
    // When
    do {
      let _ = try await sut.getRepositories(.init())
      XCTFail("The invoking should fail because server has returned a non-acceptable status")
    } catch {
      guard let apiError = error as? GitHubAPI.Error else {
        XCTFail("The thrown error should be an API error")
        return
      }
      XCTAssertEqual(
        apiError,
        GitHubAPI.Error.invalidStatusCodeInResponse(
          response: .init(statusCode: 500, headers: [], data: try .safe(from: "{}"))
        )
      )
    }
  }
}

extension APITests {
  func test_invoking_withoutCachePolicy() async throws {
    // Given
    let spy = TestInvoker.spy(invoker: TestInvoker.successInvoker)
    let sut = createSUT(invoker: spy.invoker, cachePolicy: .none)
    _ = try await sut.getRepositories(.init())
    // When
    _ = try await sut.getRepositories(.init())
    //
    XCTAssertEqual(spy.invocationCount, 2)
  }
  func test_invoking_withCachePolicy() async throws {
    // Given
    let spy = TestInvoker.spy(invoker: TestInvoker.successInvoker)
    let sut = createSUT(invoker: spy.invoker, cachePolicy: .inMemory(duration: 30))
    _ = try await sut.getRepositories(.init())
    // When
    _ = try await sut.getRepositories(.init())
    //
    XCTAssertEqual(spy.invocationCount, 1)
  }
}
