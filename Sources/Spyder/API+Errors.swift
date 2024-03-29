extension API {
  public enum Error: Swift.Error, Equatable {
    case invalidStatusCodeInResponse(response: HTTPResponse)
  }
}
