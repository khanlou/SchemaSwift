//
//  Overrides.swift
//  
//
//  Created by Soroush Khanlou on 1/22/21.
//

public struct Overrides {

    //Tables to columns to types
    public let overrides: [String: [String: String]]

    public init(overrides: [String]) {
        self.overrides = overrides.reduce(into: [String: [String: String]](), { acc, override in
            let components1 = override.split(separator: "=")
            guard components1.count == 2 else {
                fatalError("Malformed override key. Must be in the format table.column=Type.")
            }
            let columnPath = components1[0]
            let type = components1[1]
            let components2 = columnPath.split(separator: ".")
            // Should this handle schemata as well?
            guard components2.count == 2 else {
                fatalError("Malformed override key. Must be in the format table.column=Type.")
            }
            let tableName = String(components2[0])
            let columnName = String(components2[1])
            acc[tableName, default: .init()][columnName, default: .init()] = String(type)
        })
    }

    public func overrides(forTable table: String) -> [String: String] {
        overrides[table, default: .init()]
    }
}

