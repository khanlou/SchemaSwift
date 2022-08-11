//
//  Database.swift
//  
//
//  Created by Soroush Khanlou on 11/1/20.
//

import Foundation
import PostgresClientKit
import SchemaSwiftLibrary

extension Connection {
    @discardableResult
    func execute(_ sql: String, _ parameters: [PostgresValueConvertible] = []) throws -> Cursor {
        let statement = try self.prepareStatement(text: sql)
        let cursor = try statement.execute(parameterValues: parameters, retrieveColumnMetadata: true)
        return cursor
    }
}

extension ConnectionConfiguration {
    init(url: String) {
        self.init()
        let components = URLComponents(string: url)
        self.host = components?.host ?? ""
        self.database = String(components?.path.dropFirst() ?? "")
        self.user = components?.user ?? ""
        self.credential = .md5Password(password: components?.password ?? "")
    }
}

struct Database {

    let connection: Connection

    init(url: String) throws {
        connection = try Connection(configuration: .init(url: url))
    }

    func fetchEnumTypes(schema: String) throws -> [EnumDefinition] {
        try connection
            .execute("""
            SELECT n.nspname AS SCHEMA, t.typname AS name, e.enumlabel AS value
                FROM pg_type t
                JOIN pg_enum e ON t.oid = e.enumtypid
                JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
                WHERE n.nspname = $1
                ORDER BY t.typname asc, e.enumlabel asc;
            """, [schema])
            .map({ try $0.get() })
            .reduce(into: [String: [String]](), { acc, row in
                let name = try row.columns[1].string()
                let value = try row.columns[2].string()
                acc[name, default: []].append(value)
            })
            .map({ name, values in
                EnumDefinition(name: name, values: values)
            })
            .sorted(by: { $0.name < $1.name })
    }

    func fetchTableNames(schema: String) throws -> [String] {
        try connection
            .execute("SELECT tablename FROM pg_catalog.pg_tables WHERE (schemaname = $1) AND schemaname != 'pg_catalog' AND schemaname != 'information_schema' group by tablename;", [schema])
            .map({ try $0.get() })
            .compactMap({ row in
                return try? row.columns[0].string()
            })
    }

    func fetchTableDefinition(tableName: String) throws -> TableDefinition {
        let columns = try connection
            .execute("SELECT column_name, udt_name, is_nullable FROM information_schema.columns WHERE table_name = $1", [tableName])
            .map({ try $0.get() })
            .map({ row in
                return try Column(
                    name: row.columns[0].string(),
                    udtName: row.columns[1].string(),
                    isNullable: row.columns[2].string() == "YES"
                )
            })
        return TableDefinition(name: tableName, columns: columns)
    }
}

