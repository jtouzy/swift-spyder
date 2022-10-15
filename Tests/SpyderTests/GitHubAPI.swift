import Spyder

enum GitHub {}
typealias GitHubAPI = API<GitHub>

extension GitHubAPI {
  struct GetRepositoriesRequest: URLRequestBuilder {
    static var method: HTTPMethod = .get
    static var path: String = "/repositories"
  }
  struct GetRepositoriesResponse: Decodable, Equatable {
    let name: String
  }

  func getRepositories(_ input: GetRepositoriesRequest) async throws -> GetRepositoriesResponse {
    try await invokeWaitingResponse(request: input)
  }
}

extension GitHubAPI {
  static func build(using invoker: @escaping API.Invoker) -> Self {
    .init(
      baseURLComponents: { components in
        components.scheme = "https"
        components.host = "api.github.com"
      },
      invoker: invoker
    )
  }
}
