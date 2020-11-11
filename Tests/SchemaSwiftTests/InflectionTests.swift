import XCTest
@testable import SchemaSwiftLibrary

final class InflectionTests: XCTestCase {
    func testUpperCamelCase() {
        XCTAssertEqual(Inflections.upperCamelCase("users"), "Users")
        XCTAssertEqual(Inflections.upperCamelCase("one_time_passwords"), "OneTimePasswords")
        XCTAssertEqual(Inflections.upperCamelCase("_users"), "_Users")
        XCTAssertEqual(Inflections.upperCamelCase("avatar_url"), "AvatarUrl")
    }

    func testLowerCamelCase() {
        XCTAssertEqual(Inflections.lowerCamelCase("users"), "users")
        XCTAssertEqual(Inflections.lowerCamelCase("one_time_passwords"), "oneTimePasswords")
        XCTAssertEqual(Inflections.lowerCamelCase("_users"), "_users")
        XCTAssertEqual(Inflections.lowerCamelCase("avatar_url"), "avatarUrl")
    }

    func testSingularize() {
        XCTAssertEqual(Inflections.singularize("people"), "person")
        XCTAssertEqual(Inflections.singularize("monkeys"), "monkey")
        XCTAssertEqual(Inflections.singularize("users"), "user")
        XCTAssertEqual(Inflections.singularize("men"), "man")
    }

    func testPluralize() {
        XCTAssertEqual(Inflections.pluralize("person"), "people")
        XCTAssertEqual(Inflections.pluralize("monkey"), "monkeys")
        XCTAssertEqual(Inflections.pluralize("user"), "users")
        XCTAssertEqual(Inflections.pluralize("man"), "men")
    }


    static var allTests = [
        ("testUpperCamelCase", testUpperCamelCase),
        ("testLowerCamelCase", testLowerCamelCase),
    ]
}
