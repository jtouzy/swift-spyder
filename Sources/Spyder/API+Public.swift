extension API {
  public func addHeader(_ header: Header) {
    persistentHeaders.insert(header)
  }
  public var allHeaders: Set<Header> {
    var dynamicHeaders = headersBuilder()
    persistentHeaders.forEach { dynamicHeaders.insert($0) }
    return dynamicHeaders
  }
}
