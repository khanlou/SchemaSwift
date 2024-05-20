import ArgumentParser
import SchemaSwiftLibrary
import Foundation

struct SchemaSwift: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility for generating Swift row structs from a Postgres schema.",
        version: "1.0.0",
        subcommands: [Generate.self],
        defaultSubcommand: Generate.self
    )
}

struct Generate: ParsableCommand {
    @Option(help: "The full url for the Postgres server, with username, password, database name, and port.")
    var url: String

    @Option(
        name: [.customShort("o"), .long],
        help: "The location of the file containing the output. Will output to stdout if a file is not specified."
    )
    var output: String?

    @Option(
        help: "The schema in the database to generate models for. Will default to \"public\" if not specified."
    )
    var schema: String = "public"

    @Option(
        help: "A list of comma separated protocols to apply to each record struct. Codable conformance is always included. Will default to adding \"Equatable, Hashable\" if not specified."
    )
    var protocols: String = "Equatable, Hashable"

    @Option(
        help: "Overrides for the generated types. Must be in the format `table.column=Type`. May include multiple overrides."
    )
    var override: [String] = []

    func run() throws {

        let overrides = Overrides(overrides: override)
        let database = try Database(url: url)

        let enums = try database.fetchEnumTypes(schema: schema)

        let tables = try database.fetchTableNames(schema: schema).map({ try database.fetchTableDefinition(tableName: $0) })

        var string = """
        /**
         * AUTO-GENERATED FILE - \(Date()) - DO NOT EDIT!
         *
         * This file was automatically generated by SchemaSwift
         *
         */

        import Foundation


        """

        for enumDefinition in enums {
            string += """
            enum \(Inflections.upperCamelCase(Inflections.singularize(enumDefinition.name))): String, Codable, CaseIterable {
                static let enumName = "\(enumDefinition.name)"


            """

            for value in enumDefinition.values.sorted() {
                string += """
                    case \(Inflections.lowerCamelCase(normalizedForReservedKeywords(value))) = "\(value)"

                """

            }

            string += """
            }


            """
        }

        for table in tables {
            string += """
            struct \(Inflections.upperCamelCase(Inflections.singularize(table.name))): Codable\(protocols.isEmpty ? "" : ", \(protocols)") {
                static let tableName = "\(table.name)"


            """

            let overrides = overrides.overrides(forTable: table.name)

            for column in table.columns {
                string += """
                    let \(Inflections.lowerCamelCase(normalizedForReservedKeywords(column.name))): \(column.swiftType(enums: enums, overrides: overrides))

                """
            }

            string += """

                enum CodingKeys: String, CodingKey {

            """

            for column in table.columns {
                string += """
                        case \(Inflections.lowerCamelCase(normalizedForReservedKeywords(column.name))) = "\(column.name)"

                """
            }
            string += """
                }

            """


            string += """
            }


            """
        }

        if let outputPath = output {
            let url = URL(fileURLWithPath: outputPath)
            try string.write(to: url, atomically: true, encoding: .utf8)
        } else {
            print(string)
        }
    }
}

SchemaSwift.main()
