// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SchemaSwift",
    products: [
        .executable(name: "SchemaSwift", targets: ["SchemaSwift"]),
        .library(name: "SchemaSwiftLibrary", targets: ["SchemaSwiftLibrary"]),
    ],
    dependencies: [
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
        .package(url: "https://github.com/codewinsdotcom/PostgresClientKit", from: "1.4.3"),
    ],
    targets: [
        .target(
            name: "SchemaSwiftLibrary",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "PostgresClientKit", package: "PostgresClientKit"),
            ]),
        .target(
            name: "SchemaSwift",
            dependencies: ["SchemaSwiftLibrary"]),
        .testTarget(
            name: "SchemaSwiftTests",
            dependencies: ["SchemaSwiftLibrary"]),
    ]
)
