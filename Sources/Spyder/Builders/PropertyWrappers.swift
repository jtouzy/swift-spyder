@propertyWrapper
public struct RequestHeader {
  let name: String
  public var wrappedValue = ""

  public init(name: String) {
    self.name = name
  }
}

@propertyWrapper
public struct PathArgument {
  let name: String
  public var wrappedValue = ""

  public init(name: String) {
    self.name = name
  }
}

@propertyWrapper
public struct QueryArgument {
  let name: String
  public var wrappedValue = ""

  public init(name: String) {
    self.name = name
  }
}

@propertyWrapper
public struct OptionalQueryArgument {
  let name: String
  public var wrappedValue: String? = .none

  public init(name: String) {
    self.name = name
  }
}

@propertyWrapper
public struct Body {
  public var wrappedValue: any Encodable

  public init(wrappedValue: any Encodable) {
    self.wrappedValue = wrappedValue
  }
}
