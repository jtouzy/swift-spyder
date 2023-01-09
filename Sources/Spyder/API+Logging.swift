import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension API {
  internal func logInvoke(for urlRequest: URLRequest, isCached: Bool) {
    logger(
      "🕸️ invoke\(isCached ? " [CACHED]" : "")",
      [
        "method=[\(urlRequest.httpMethod ?? "GET")]",
        "absolute_url=[\(urlRequest.url?.absoluteString ?? "nil")]",
        "headers=[\(urlRequest.allHTTPHeaderFields ?? [:])]",
        "body=[\(urlRequest.httpBody?.jsonString(options: .prettyPrinted) ?? "nil")]"
      ].joined(separator: ", ")
    )
  }
  internal func logResponse(for urlRequest: URLRequest, response: HTTPResponse) {
    let isSuccess = (200...299).contains(response.statusCode)
    logNetworkingEvent(
      for: urlRequest,
      message: "\(isSuccess ? "✅ success" : "❌ failure")[\(response.statusCode)]"
    )
  }
  internal func logInvocationFailure(for urlRequest: URLRequest, error: Swift.Error) {
    logNetworkingEvent(
      for: urlRequest,
      message: "❌ invocationFailure",
      complementaryMessage: String(reflecting: error)
    )
  }
  internal func logDecodingError(for urlRequest: URLRequest, error: Swift.Error) {
    logNetworkingEvent(
      for: urlRequest,
      message: "❌ decodingFailure",
      complementaryMessage: String(reflecting: error)
    )
  }
}

extension API {
  private func logNetworkingEvent(for urlRequest: URLRequest, message: String, complementaryMessage: String? = .none) {
    let complementary: String = {
      guard let url = urlRequest.url else {
        return ""
      }
      let method = urlRequest.httpMethod ?? "GET"
      var complementary = "path=[\(method.uppercased()) \(url.relativePath)]"
      if let complementaryMessage = complementaryMessage {
        complementary += " message=[\(complementaryMessage)]"
      }
      return complementary
    }()
    logger(message, complementary)
  }
}

private extension Data {
  func jsonString(options: JSONSerialization.WritingOptions = []) -> String? {
    guard
      let object = try? JSONSerialization.jsonObject(with: self, options: []),
      let data = try? JSONSerialization.data(withJSONObject: object, options: options),
      let jsonString = String(data: data, encoding: .utf8)
    else {
      return nil
    }
    return jsonString
  }
}
