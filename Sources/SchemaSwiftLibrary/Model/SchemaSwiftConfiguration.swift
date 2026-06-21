import Foundation

public struct SchemaSwiftConfiguration: Codable, Equatable {
    public var url: String?
    public var urlEnvironmentVariable: String?
    public var envFile: String?
    public var output: String
    public var schema: String?
    public var protocols: [String]?
    public var swiftNamespace: String?
    public var trimTrailingWhitespace: Bool?
    public var overrides: [String]?

    public init(
        url: String? = nil,
        urlEnvironmentVariable: String? = nil,
        envFile: String? = nil,
        output: String,
        schema: String? = nil,
        protocols: [String]? = nil,
        swiftNamespace: String? = nil,
        trimTrailingWhitespace: Bool? = nil,
        overrides: [String]? = nil
    ) {
        self.url = url
        self.urlEnvironmentVariable = urlEnvironmentVariable
        self.envFile = envFile
        self.output = output
        self.schema = schema
        self.protocols = protocols
        self.swiftNamespace = swiftNamespace
        self.trimTrailingWhitespace = trimTrailingWhitespace
        self.overrides = overrides
    }

    enum CodingKeys: String, CodingKey {
        case url
        case urlEnvironmentVariable
        case envFile
        case output
        case schema
        case protocols
        case swiftNamespace
        case trimTrailingWhitespace
        case overrides
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.urlEnvironmentVariable = try container.decodeIfPresent(String.self, forKey: .urlEnvironmentVariable)
        self.envFile = try container.decodeIfPresent(String.self, forKey: .envFile)
        self.output = try container.decodeRequiredOutput(forKey: .output)
        self.schema = try container.decodeIfPresent(String.self, forKey: .schema)
        self.protocols = try container.decodeProtocolListIfPresent(forKey: .protocols)
        self.swiftNamespace = try container.decodeIfPresent(String.self, forKey: .swiftNamespace)
        self.trimTrailingWhitespace = try container.decodeIfPresent(Bool.self, forKey: .trimTrailingWhitespace)
        self.overrides = try container.decodeIfPresent([String].self, forKey: .overrides)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(urlEnvironmentVariable, forKey: .urlEnvironmentVariable)
        try container.encodeIfPresent(envFile, forKey: .envFile)
        try container.encode(output, forKey: .output)
        try container.encodeIfPresent(schema, forKey: .schema)
        try container.encodeIfPresent(protocols, forKey: .protocols)
        try container.encodeIfPresent(swiftNamespace, forKey: .swiftNamespace)
        try container.encodeIfPresent(trimTrailingWhitespace, forKey: .trimTrailingWhitespace)
        try container.encodeIfPresent(overrides, forKey: .overrides)
    }

    public static func protocols(from commaSeparatedString: String) -> [String] {
        commaSeparatedString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

extension KeyedDecodingContainer {
    func decodeRequiredOutput(forKey key: Key) throws -> String {
        let output = try decodeIfPresent(String.self, forKey: key)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard let output, !output.isEmpty else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "SchemaSwift configuration files must include a non-empty output path."
                )
            )
        }

        return output
    }

    func decodeProtocolListIfPresent(forKey key: Key) throws -> [String]? {
        guard contains(key) else {
            return nil
        }

        if let protocols = try? decodeIfPresent([String].self, forKey: key) {
            return protocols
        }

        if let protocols = try? decodeIfPresent(String.self, forKey: key) {
            return SchemaSwiftConfiguration.protocols(from: protocols)
        }

        throw DecodingError.typeMismatch(
            [String].self,
            DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: "Expected an array of protocol names or a comma-separated string."
            )
        )
    }
}
