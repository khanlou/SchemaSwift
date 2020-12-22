//
//  Database.swift
//  
//
//  Created by Soroush Khanlou on 11/1/20.
//

import Foundation
import SwiftgreSQL
import SchemaSwiftLibrary

struct Database {

    let connection: Connection

    init(url: String) throws {
        connection = try Connection(connInfo: url)
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
            .reduce(into: [String: [String]](), { acc, row in
                guard let name = row["name"]?.string, let value = row["value"]?.string else {
                    return
                }
                acc[name, default: []].append(value)
            })
            .map({ name, values in
                EnumDefinition(name: name, values: values)
            })
    }

    func fetchTableNames(schema: String) throws -> [String] {
        try connection
            .execute("SELECT tablename FROM pg_catalog.pg_tables WHERE (schemaname = $1) AND schemaname != 'pg_catalog' AND schemaname != 'information_schema' group by tablename;", [schema])
            .compactMap({ row in
                return row["tablename"]?.string
            })
    }

    func fetchTableDefinition(tableName: String) throws -> TableDefinition {
        let columns = try connection
            .execute("SELECT column_name, udt_name, is_nullable FROM information_schema.columns WHERE table_name = $1", [tableName])
            .map({ row in
                return Column(
                    name: row["column_name"]?.string ?? "",
                    udtName: row["udt_name"]?.string ?? "",
                    isNullable: row["is_nullable"]?.string ?? "" == "YES"
                )
            })
        return TableDefinition(name: tableName, columns: columns)
    }
}

