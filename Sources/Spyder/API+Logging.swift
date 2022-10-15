import Foundation

extension API {
  internal func logResponse(for urlRequest: URLRequest, response: HTTPResponse) {
    let isSuccess = (200...299).contains(response.statusCode)
    logNetworkingEvent(
      for: urlRequest,
      message: "\(isSuccess ? "✅ success" : "❌ failure")[\(response.statusCode)]"
    )
  }
  internal func logInvocationFailure(for urlRequest: URLRequest, error: Error) {
    logNetworkingEvent(
      for: urlRequest,
      message: "❌ invocationFailure",
      complementaryMessage: String(reflecting: error)
    )
  }
  internal func logDecodingError(for urlRequest: URLRequest, error: Error) {
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
