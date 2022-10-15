import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession {
  public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    #if os(Linux)
    return try await urlSessionWithContinuation(request: request)
    #else
    if #available(iOS 15.0, macOS 12.0, *) {
      return try await data(for: request, delegate: nil)
    } else {
      return try await urlSessionWithContinuation(request: request)
    }
    #endif
  }
}

private enum URLSessionError: Error {
  case inconsistentDataTaskResponse
}

private func urlSessionWithContinuation(request: URLRequest) async throws -> (Data, URLResponse) {
  try await withCheckedThrowingContinuation { continuation in
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        continuation.resume(throwing: error)
      } else if let data = data, let response = response {
        continuation.resume(returning: (data, response))
      } else {
        continuation.resume(throwing: URLSessionError.inconsistentDataTaskResponse)
      }
    }
    task.resume()
  }
}
