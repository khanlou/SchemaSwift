import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ConfigurationTests.allTests),
        testCase(InflectionTests.allTests),
    ]
}
#endif
