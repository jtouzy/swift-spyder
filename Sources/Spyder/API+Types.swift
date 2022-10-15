import Foundation

public enum HTTPMethod: String {
  case delete, get, post, put
}

public struct HTTPResponse {
  public let statusCode: Int
  public let data: Data

  public init(statusCode: Int, data: Data) {
    self.statusCode = statusCode
    self.data = data
  }
}

public struct Header: Hashable {
  let name: String
  let value: String

  public init(name: String, value: String) {
    self.name = name
    self.value = value
  }
}

extension Header {
  public enum ContentType: String {
    case image = "image/jpeg"
    case json = "application/json"
    case text = "text/plain"
  }

  public static func contentType(_ value: Header.ContentType) -> Self {
    .init(
      name: "Content-Type",
      value: value.rawValue
    )
  }
}
