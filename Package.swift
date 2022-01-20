// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftThreadSafe",
    products: [
        .library(name: "SwiftThreadSafe", targets: ["SwiftThreadSafe"])
    ],
    dependencies: [],
    targets: [
        .target(name: "SwiftThreadSafe", dependencies: []),
        .testTarget(name: "SwiftThreadSafeTests", dependencies: ["SwiftThreadSafe"])
    ]
)
