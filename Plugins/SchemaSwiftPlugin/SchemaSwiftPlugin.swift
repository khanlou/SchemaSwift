import Foundation
import PackagePlugin

@main
struct SchemaSwiftPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let tool = try context.tool(named: "SchemaSwift")
        try runSchemaSwift(
            toolPath: tool.path,
            packageDirectory: context.package.directory,
            arguments: arguments
        )
    }
}

private func runSchemaSwift(toolPath: Path, packageDirectory: Path, arguments: [String]) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: toolPath.string)
    process.currentDirectoryURL = URL(fileURLWithPath: packageDirectory.string)
    process.arguments = arguments
    process.environment = environment(packageDirectory: packageDirectory)

    try process.run()
    process.waitUntilExit()

    guard process.terminationReason == .exit && process.terminationStatus == 0 else {
        throw SchemaSwiftPluginError.schemaSwiftFailed(process.terminationStatus)
    }
}

private func environment(packageDirectory: Path) -> [String: String] {
    let packageDirectoryURL = URL(fileURLWithPath: packageDirectory.string)
    let envFileURL = packageDirectoryURL.appendingPathComponent(".env.local")
    var environment = ProcessInfo.processInfo.environment

    guard let contents = try? String(contentsOf: envFileURL, encoding: .utf8) else {
        return environment
    }

    for (key, value) in parseEnvironmentFile(contents) where environment[key] == nil {
        environment[key] = value
    }

    return environment
}

private func parseEnvironmentFile(_ contents: String) -> [String: String] {
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

enum SchemaSwiftPluginError: Error, CustomStringConvertible {
    case schemaSwiftFailed(Int32)

    var description: String {
        switch self {
        case .schemaSwiftFailed(let status):
            return "SchemaSwift exited with status \(status)."
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SchemaSwiftPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "SchemaSwift")
        try runSchemaSwift(
            toolPath: tool.path,
            packageDirectory: context.xcodeProject.directory,
            arguments: arguments
        )
    }
}
#endif
