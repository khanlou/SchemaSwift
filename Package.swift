// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "SchemaSwift",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "SchemaSwift", targets: ["SchemaSwift"]),
        .library(name: "SchemaSwiftLibrary", targets: ["SchemaSwiftLibrary"]),
        .plugin(name: "SchemaSwiftPlugin", targets: ["SchemaSwiftPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/vapor/postgres-kit.git", from: "2.12.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SchemaSwiftLibrary",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "PostgresKit", package: "postgres-kit"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ]),
        .executableTarget(
            name: "SchemaSwift",
            dependencies: ["SchemaSwiftLibrary"]),
        .plugin(
            name: "SchemaSwiftPlugin",
            capability: .command(
                intent: .custom(
                    verb: "schemaswift",
                    description: "Generate Swift row structs from a Postgres schema."
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Writes generated Swift output configured by SchemaSwift."),
                    .allowNetworkConnections(
                        scope: .all(ports: [5432]),
                        reason: "Connects to Postgres to read schema metadata."
                    ),
                ]
            ),
            dependencies: ["SchemaSwift"]),
        .testTarget(
            name: "SchemaSwiftTests",
            dependencies: ["SchemaSwiftLibrary"]),
    ]
)
