import Foundation

public enum EnvironmentFile {
    public static func parse(_ contents: String) -> [String: String] {
        contents
            .split(whereSeparator: \.isNewline)
            .reduce(into: [String: String]()) { environment, rawLine in
                var line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !line.isEmpty, !line.hasPrefix("#") else {
                    return
                }

                if line.hasPrefix("export ") {
                    line.removeFirst("export ".count)
                    line = line.trimmingCharacters(in: .whitespacesAndNewlines)
                }

                guard let equalsIndex = line.firstIndex(of: "=") else {
                    return
                }

                let key = line[..<equalsIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                let rawValue = line[line.index(after: equalsIndex)...].trimmingCharacters(in: .whitespacesAndNewlines)

                guard !key.isEmpty else {
                    return
                }

                environment[key] = rawValue.removingMatchingQuotes()
            }
    }
}

public enum EnvironmentExpansion {
    public static func expand(_ value: String, environment: [String: String]) throws -> String {
        var result = ""
        var index = value.startIndex

        while index < value.endIndex {
            let nextIndex = value.index(after: index)

            if value[index] == "$", nextIndex < value.endIndex, value[nextIndex] == "{" {
                let variableStart = value.index(after: nextIndex)

                guard let variableEnd = value[variableStart...].firstIndex(of: "}") else {
                    throw EnvironmentExpansionError.unterminatedVariable
                }

                let variableName = String(value[variableStart..<variableEnd])

                guard let variableValue = environment[variableName] else {
                    throw EnvironmentExpansionError.missingVariable(variableName)
                }

                result += variableValue
                index = value.index(after: variableEnd)
            } else {
                result.append(value[index])
                index = nextIndex
            }
        }

        return result
    }
}

public enum EnvironmentExpansionError: Error, CustomStringConvertible {
    case missingVariable(String)
    case unterminatedVariable

    public var description: String {
        switch self {
        case .missingVariable(let variable):
            return "Environment variable '\(variable)' is not set."
        case .unterminatedVariable:
            return "Unterminated environment variable reference. Use the format ${VARIABLE_NAME}."
        }
    }
}

private extension String {
    func removingMatchingQuotes() -> String {
        guard count >= 2 else {
            return self
        }

        if hasPrefix("\""), hasSuffix("\"") {
            return String(dropFirst().dropLast())
        }

        if hasPrefix("'"), hasSuffix("'") {
            return String(dropFirst().dropLast())
        }

        return self
    }
}
