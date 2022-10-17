@testable import Spyder
import XCTest

final class URLRequestBuilderTests: XCTestCase {
}

// ========================================================================
// MARK: XCAssertion addition
// ========================================================================

private func XCTAssertURLRequestEquals(
  _ request: URLRequest,
  headers: [Header] = [],
  url: String,
  httpMethod: HTTPMethod,
  body: Data?
) {
  guard let generatedURL = request.url?.absoluteString else {
    XCTFail("Generated URL is missing on \(request)")
    return
  }
  guard let generatedHttpMethod = request.httpMethod else {
    XCTFail("Generated HTTPMethod is missing on \(request)")
    return
  }
  if let requestHeaders = request.allHTTPHeaderFields {
    let generatedHeaderKeys = requestHeaders.keys.sorted(by: { $0 < $1 })
    let expectedHeaderKeys = headers.map(\.name).sorted(by: { $0 < $1 })
    XCTAssertEqual(generatedHeaderKeys, expectedHeaderKeys)
    expectedHeaderKeys.forEach { expectedHeaderKey in
      let expectedHeader = headers.first(where: { $0.name == expectedHeaderKey })!
      let generatedHeader = requestHeaders[expectedHeaderKey]!
      XCTAssertEqual(expectedHeader.value, generatedHeader, "Header \(expectedHeader.name) is different")
    }
  } else if headers.isEmpty == false {
    XCTFail("Generated headers are different expected headers \(request)")
  }
  XCTAssertEqual(generatedURL, url)
  XCTAssertEqual(generatedHttpMethod.lowercased(), httpMethod.rawValue)
  XCTAssertEqual(request.httpBody, body)
}

// ========================================================================
// MARK: URLRequestBuilderTests: HTTPMethod-related tests
// ========================================================================

extension URLRequestBuilderTests {
  struct NoQueryNoPathGetRequestExample: URLRequestBuilder {
    static let method: HTTPMethod = .get
    static let path: String = "/api/v1/getRequestExample"
  }
  struct NoQueryNoPathPostRequestExample: URLRequestBuilder {
    static let method: HTTPMethod = .post
    static let path: String = "/api/v1/getRequestExample"
  }
}

extension URLRequestBuilderTests {
  func test_noQueryNoPathGetRequestExample() throws {
    // Given
    let builder = NoQueryNoPathGetRequestExample()
    // When
    let urlRequest = try builder.urlRequest(for: GitHubAPI.build(using: Invoker.defaultHTTPInvoker))
    // Then
    XCTAssertURLRequestEquals(
      urlRequest,
      url: "https://api.github.com/api/v1/getRequestExample",
      httpMethod: .get,
      body: .none
    )
  }
  func test_noQueryNoPathPostRequestExample() throws {
    // Given
    let builder = NoQueryNoPathPostRequestExample()
    // When
    let urlRequest = try builder.urlRequest(for: GitHubAPI.build(using: Invoker.defaultHTTPInvoker))
    // Then
    XCTAssertURLRequestEquals(
      urlRequest,
      url: "https://api.github.com/api/v1/getRequestExample",
      httpMethod: .post,
      body: .none
    )
  }
}

// ========================================================================
// MARK: URLRequestBuilderTests: Headers tests
// ========================================================================

extension URLRequestBuilderTests {
  struct NoQueryNoPathGetWithHeadersRequestExample: URLRequestBuilder {
    static let method: HTTPMethod = .get
    static let path: String = "/api/v1/getRequestExample"
    @RequestHeader(name: "spyder-auth") var auth: String
    init(auth: String) { self.auth = auth }
  }
}

extension URLRequestBuilderTests {
  func test_noQueryNoPathGetRequestHeadersExample() throws {
    // Given
    let builder = NoQueryNoPathGetWithHeadersRequestExample(auth: "auth-value")
    // When
    let urlRequest = try builder.urlRequest(for: GitHubAPI.build(using: Invoker.defaultHTTPInvoker))
    // Then
    XCTAssertURLRequestEquals(
      urlRequest,
      headers: [.init(name: "spyder-auth", value: "auth-value")],
      url: "https://api.github.com/api/v1/getRequestExample",
      httpMethod: .get,
      body: .none
    )
  }
  func test_noQueryNoPathGetRequestHeadersAndApiHeadersExample() throws {
    // Given
    let builder = NoQueryNoPathGetWithHeadersRequestExample(auth: "auth-value")
    let api = GitHubAPI.build(using: Invoker.defaultHTTPInvoker)
    api.addHeader(.init(name: "spyder-additional-header", value: "Value!"))
    // When
    let urlRequest = try builder.urlRequest(for: api)
    // Then
    XCTAssertURLRequestEquals(
      urlRequest,
      headers: [
        .init(name: "spyder-auth", value: "auth-value"),
        .init(name: "spyder-additional-header", value: "Value!")
      ],
      url: "https://api.github.com/api/v1/getRequestExample",
      httpMethod: .get,
      body: .none
    )
  }
}

// ========================================================================
// MARK: URLRequestBuilderTests: Query parameters tests
// ========================================================================

extension URLRequestBuilderTests {
  struct QueryNoPathGetRequestExample: URLRequestBuilder {
    static let method: HTTPMethod = .get
    static let path: String = "/api/v1/getRequestExample"
    @QueryArgument(name: "queryItem") var value: String
    init(value: String) { self.value = value }
  }
  struct MutlipleQueryNoPathGetRequestExample: URLRequestBuilder {
    static let method: HTTPMethod = .get
    static let path: String = "/api/v1/getRequestExample"
    @QueryArgument(name: "queryItem") var value: String
    @QueryArgument(name: "secondQueryItem") var secondValue: String
    init(value: String, secondValue: String) { self.value = value; self.secondValue = secondValue }
  }
}

extension URLRequestBuilderTests {
  func test_queryNoPathGetRequestExample() throws {
    // Given
    let builder = QueryNoPathGetRequestExample(value: "queryItemValue")
    // When
    let urlRequest = try builder.urlRequest(for: GitHubAPI.build(using: Invoker.defaultHTTPInvoker))
    // Then
    XCTAssertURLRequestEquals(
      urlRequest,
      url: "https://api.github.com/api/v1/getRequestExample?queryItem=queryItemValue",
      httpMethod: .get,
      body: .none
    )
  }
  func test_multipleQueryNoPathGetRequestExample() throws {
    // Given
    let builder = MutlipleQueryNoPathGetRequestExample(value: "queryItemValue", secondValue: "secQueryValue")
    // When
    let urlRequest = try builder.urlRequest(for: GitHubAPI.build(using: Invoker.defaultHTTPInvoker))
    // Then
    XCTAssertURLRequestEquals(
      urlRequest,
      url: "https://api.github.com/api/v1/getRequestExample?queryItem=queryItemValue&secondQueryItem=secQueryValue",
      httpMethod: .get,
      body: .none
    )
  }
}

// ========================================================================
// MARK: URLRequestBuilderTests: Path parameters tests
// ========================================================================

extension URLRequestBuilderTests {
  struct NoQueryPathGetRequestExample: URLRequestBuilder {
    static let method: HTTPMethod = .get
    static let path: String = "/api/v1/{pathParam}/getRequestExample"
    @PathArgument(name: "pathParam") var value: String
    init(value: String) { self.value = value }
  }
}

extension URLRequestBuilderTests {
  func test_noQueryPathGetRequestExample() throws {
    // Given
    let builder = NoQueryPathGetRequestExample(value: "pathValue")
    // When
    let urlRequest = try builder.urlRequest(for: GitHubAPI.build(using: Invoker.defaultHTTPInvoker))
    // Then
    XCTAssertURLRequestEquals(
      urlRequest,
      url: "https://api.github.com/api/v1/pathValue/getRequestExample",
      httpMethod: .get,
      body: .none
    )
  }
}

// ========================================================================
// MARK: URLRequestBuilderTests: Body tests
// ========================================================================

extension URLRequestBuilderTests {
  struct ContentBody: Codable {
    let value: String
  }
  struct NoQueryNoPathBodyPostRequestExample: URLRequestBuilder {
    static let method: HTTPMethod = .post
    static let path: String = "/api/v1/postRequestExample"
    @Body var value: any Encodable
    init(value: ContentBody) { self.value = value }
  }
}

extension URLRequestBuilderTests {
  func test_noQueryNoPathBodyPostRequestExample() throws {
    // Given
    let api = GitHubAPI.build(using: Invoker.defaultHTTPInvoker)
    let builder = NoQueryNoPathBodyPostRequestExample(value: .init(value: "ContentBodyValue"))
    let expectedBody = try? api.jsonEncoder.encode(ContentBody(value: "ContentBodyValue"))
    // When
    let urlRequest = try builder.urlRequest(for: api)
    // Then
    XCTAssertURLRequestEquals(
      urlRequest,
      url: "https://api.github.com/api/v1/postRequestExample",
      httpMethod: .post,
      body: expectedBody
    )
  }
}
