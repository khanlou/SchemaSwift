import XCTest
@testable import SchemaSwiftLibrary

final class ConfigurationTests: XCTestCase {
    func testDecodesConfiguration() throws {
        let data = """
        {
          "url": "postgres://user:password@localhost:5432/database",
          "urlEnvironmentVariable": "SCHEMASWIFT_DATABASE_URL",
          "envFile": ".env.local",
          "output": "Sources/App/Generated/Database.swift",
          "schema": "public",
          "protocols": ["Equatable", "Hashable", "Identifiable"],
          "swiftNamespace": "DB",
          "trimTrailingWhitespace": true,
          "overrides": [
            "users.email=Email"
          ]
        }
        """.data(using: .utf8)!

        let configuration = try JSONDecoder().decode(SchemaSwiftConfiguration.self, from: data)

        XCTAssertEqual(configuration.url, "postgres://user:password@localhost:5432/database")
        XCTAssertEqual(configuration.urlEnvironmentVariable, "SCHEMASWIFT_DATABASE_URL")
        XCTAssertEqual(configuration.envFile, ".env.local")
        XCTAssertEqual(configuration.output, "Sources/App/Generated/Database.swift")
        XCTAssertEqual(configuration.schema, "public")
        XCTAssertEqual(configuration.protocols, ["Equatable", "Hashable", "Identifiable"])
        XCTAssertEqual(configuration.swiftNamespace, "DB")
        XCTAssertEqual(configuration.trimTrailingWhitespace, true)
        XCTAssertEqual(configuration.overrides, ["users.email=Email"])
    }

    func testDecodesProtocolsFromCommaSeparatedString() throws {
        let data = """
        {
          "output": "Sources/App/Generated/Database.swift",
          "protocols": "Equatable, Hashable, Identifiable"
        }
        """.data(using: .utf8)!

        let configuration = try JSONDecoder().decode(SchemaSwiftConfiguration.self, from: data)

        XCTAssertEqual(configuration.protocols, ["Equatable", "Hashable", "Identifiable"])
    }

    func testRequiresOutput() {
        let data = """
        {
          "schema": "public"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(SchemaSwiftConfiguration.self, from: data))
    }

    func testParsesEnvironmentFile() {
        let contents = """
        # Local secrets
        SCHEMASWIFT_DATABASE_URL=postgres://user:password@localhost:5432/database
        QUOTED_URL="postgres://quoted@localhost:5432/database"
        export SINGLE_QUOTED_URL='postgres://single-quoted@localhost:5432/database'
        """

        let environment = EnvironmentFile.parse(contents)

        XCTAssertEqual(environment["SCHEMASWIFT_DATABASE_URL"], "postgres://user:password@localhost:5432/database")
        XCTAssertEqual(environment["QUOTED_URL"], "postgres://quoted@localhost:5432/database")
        XCTAssertEqual(environment["SINGLE_QUOTED_URL"], "postgres://single-quoted@localhost:5432/database")
    }

    func testExpandsEnvironmentVariables() throws {
        let expanded = try EnvironmentExpansion.expand(
            "postgres://${DATABASE_HOST}:5432/database",
            environment: ["DATABASE_HOST": "localhost"]
        )

        XCTAssertEqual(expanded, "postgres://localhost:5432/database")
    }

    func testThrowsForMissingEnvironmentVariable() {
        XCTAssertThrowsError(try EnvironmentExpansion.expand("${MISSING_DATABASE_URL}", environment: [:]))
    }

    static var allTests = [
        ("testDecodesConfiguration", testDecodesConfiguration),
        ("testDecodesProtocolsFromCommaSeparatedString", testDecodesProtocolsFromCommaSeparatedString),
        ("testRequiresOutput", testRequiresOutput),
        ("testParsesEnvironmentFile", testParsesEnvironmentFile),
        ("testExpandsEnvironmentVariables", testExpandsEnvironmentVariables),
        ("testThrowsForMissingEnvironmentVariable", testThrowsForMissingEnvironmentVariable),
    ]
}
