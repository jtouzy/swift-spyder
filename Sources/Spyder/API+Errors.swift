extension API {
  enum Error: Swift.Error, Equatable {
    case invalidStatusCodeInResponse(response: HTTPResponse)
  }
}
