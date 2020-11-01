// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SchemaSwift",
    products: [
        .executable(name: "SchemaSwift", targets: ["SchemaSwift"]),
        .library(name: "SchemaSwiftLibrary", targets: ["SchemaSwiftLibrary"]),
    ],
    dependencies: [
        .package(name: "SwiftgreSQL", url: "https://github.com/khanlou/SwiftgresQL", from: "0.1.2"),
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "SchemaSwiftLibrary",
            dependencies: ["SwiftgreSQL", .product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .target(
            name: "SchemaSwift",
            dependencies: ["SchemaSwiftLibrary"]),
        .testTarget(
            name: "SchemaSwiftTests",
            dependencies: ["SchemaSwiftLibrary"]),
    ]
)
