//
//  Database.swift
//  
//
//  Created by Soroush Khanlou on 11/1/20.
//

import Foundation
import AsyncKit
import PostgresKit
import SchemaSwiftLibrary

struct Database: @unchecked Sendable {

    let pools: EventLoopGroupConnectionPool<PostgresConnectionSource>

    public init(loopGroup: EventLoopGroup = .singletonMultiThreadedEventLoopGroup, url: String) throws {
        var configuration = try SQLPostgresConfiguration(url: url)
        var tlsConfig = TLSConfiguration.makeClientConfiguration()
        tlsConfig.certificateVerification = .none
        configuration.coreConfiguration.tls = try .prefer(.init(configuration: tlsConfig))

        self.pools = EventLoopGroupConnectionPool(
            source: PostgresConnectionSource(sqlConfiguration: configuration),
            on: loopGroup
        )
    }

    @discardableResult
    func execute(_ sql: SQLQueryString) -> SQLRawBuilder {
        return self.pools.database(logger: Logger(label: "postgres"))
            .sql()
            .raw(sql)
    }

    func shutdown() async throws {
        try await pools.shutdownAsync()
    }

    func fetchEnumTypes(schema: String) async throws -> [EnumDefinition] {
        struct EnumDef: Decodable {
            let name: String
            let value: String
        }
        return try await execute("""
            SELECT n.nspname AS SCHEMA, t.typname AS name, e.enumlabel AS value
                FROM pg_type t
                JOIN pg_enum e ON t.oid = e.enumtypid
                JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
                WHERE n.nspname = \(bind: schema)
                ORDER BY t.typname asc, e.enumlabel asc;
            """)
        .all(decoding: EnumDef.self)
        .reduce(into: [String: [String]](), { acc, enumDef in
            acc[enumDef.name, default: []].append(enumDef.value)
        })
        .map({ name, values in
            EnumDefinition(name: name, values: values)
        })
        .sorted(by: { $0.name < $1.name })
    }

    func fetchTableNames(schema: String) async throws -> [String] {
        struct TableName: Decodable {
            let tablename: String
        }
        return try await execute("SELECT tablename FROM pg_catalog.pg_tables WHERE (schemaname = \(bind: schema)) AND schemaname != 'pg_catalog' AND schemaname != 'information_schema' group by tablename;")
            .all(decoding: TableName.self)
            .map(\.tablename)
            .sorted()
    }

    func fetchTableDefinition(tableName: String) async throws -> TableDefinition {
        struct ColumnDefinition: Decodable {
            let column_name: String
            let udt_name: String
            let is_nullable: String
        }
        let columns = try await execute("SELECT column_name, udt_name, is_nullable FROM information_schema.columns WHERE table_name = \(bind: tableName) ORDER BY ordinal_position")
            .all(decoding: ColumnDefinition.self)
            .map({
                Column(
                    name: $0.column_name,
                    udtName: $0.udt_name,
                    isNullable: $0.is_nullable == "YES"
                )
            })
        return TableDefinition(name: tableName, columns: columns)
    }
}

