import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol URLRequestBuilder {
  static var method: HTTPMethod { get }
  static var path: String { get }
}

enum URLRequestBuildingError: Swift.Error {
  case unableToBuildFinalURL
}

extension URLRequestBuilder {
  func urlRequest<ConstrainedType>(for api: API<ConstrainedType>) throws -> URLRequest {
    let mirror = Mirror(reflecting: self)
    var evaluatedPath = Self.path
    var headers: Set<Header> = api.allHeaders
    var queryItems: [URLQueryItem] = []
    var httpBody: Data?
    for child in mirror.children {
      switch child.value {
      case let header as RequestHeader:
        updateHeaders(&headers, header: header)
      case let pathArgument as PathArgument:
        evaluatedPath = updatePath(from: evaluatedPath, argument: pathArgument)
      case let queryArgument as QueryArgument:
        updateQueryItems(&queryItems, argument: queryArgument)
      case let optionalQueryArgument as OptionalQueryArgument:
        updateQueryItems(&queryItems, argument: optionalQueryArgument)
      case let body as Body:
        httpBody = try createBody(from: body, using: api.jsonEncoder)
      default:
        break
      }
    }
    var components = api.baseURLComponents
    components.path = evaluatedPath
    if queryItems.isEmpty == false {
      components.queryItems = queryItems
    }
    guard let url = components.url else {
      throw URLRequestBuildingError.unableToBuildFinalURL
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = Self.method.rawValue
    urlRequest.httpBody = httpBody
    headers.forEach { header in
      urlRequest.setValue(header.value, forHTTPHeaderField: header.name)
    }
    return urlRequest
  }
}

private func updateHeaders(_ headers: inout Set<Header>, header: RequestHeader) {
  headers.insert(.init(name: header.name, value: header.wrappedValue))
}
private func updatePath(from path: String, argument: PathArgument) -> String {
  path.replacingOccurrences(of: "{\(argument.name)}", with: argument.wrappedValue)
}
private func updateQueryItems(_ queryItems: inout [URLQueryItem], argument: QueryArgument) {
  queryItems.append(URLQueryItem(name: argument.name, value: argument.wrappedValue))
}
private func updateQueryItems(_ queryItems: inout [URLQueryItem], argument: OptionalQueryArgument) {
  if let wrappedValue = argument.wrappedValue {
    queryItems.append(URLQueryItem(name: argument.name, value: wrappedValue))
  }
}
private func createBody(from content: Body, using encoder: JSONEncoder) throws -> Data? {
  try encoder.encode(content.wrappedValue)
}
