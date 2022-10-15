import Foundation

// MARK: API invoking functions

extension API {
  public func invokeAndForget<Input>(request: Input) async throws
  where Input: URLRequestBuilder {
    let urlRequest = try request.urlRequest(for: self)
    do {
      let response = try await invoker(urlRequest)
      logResponse(for: urlRequest, response: response)
    } catch {
      logInvocationFailure(for: urlRequest, error: error)
      throw error
    }
  }
  public func invokeWaitingResponse<Input, Output>(request: Input) async throws -> Output
  where Input: URLRequestBuilder, Output: Decodable {
    let urlRequest = try request.urlRequest(for: self)
    let response: HTTPResponse = try await {
      do {
        var response = try await invoker(urlRequest)
        logResponse(for: urlRequest, response: response)
        for middleware in responseMiddlewares {
          response = try await middleware(self, response)
        }
        return response
      } catch {
        logInvocationFailure(for: urlRequest, error: error)
        throw error
      }
    }()
    do {
      return try jsonDecoder.decode(Output.self, from: response.data)
    } catch {
      logDecodingError(for: urlRequest, error: error)
      throw error
    }
  }
}

// MARK: Invokers

public enum Invoker {
  public static let defaultHTTPInvoker: API.Invoker = { request in
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw Invoker.DefaultHTTPInvokerError.missingHTTPResponse
    }
    return .init(statusCode: httpResponse.statusCode, data: data)
  }
}
extension Invoker {
  enum DefaultHTTPInvokerError: Swift.Error {
    case missingHTTPResponse
  }
}
