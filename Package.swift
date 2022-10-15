// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "swift-spyder",
  platforms: [
    .iOS(.v14),
    .macOS(.v11)
  ],
  products: [
    .library(
      name: "Spyder",
      targets: ["Spyder"]
    )
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Spyder",
      dependencies: []
    ),
    .testTarget(
      name: "SpyderTests",
      dependencies: ["Spyder"]
    )
  ]
)
