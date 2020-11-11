//
//  Column.swift
//  
//
//  Created by Soroush Khanlou on 11/1/20.
//

import Foundation

public struct Column {
    public init(name: String, udtName: String, isNullable: Bool) {
        self.name = name
        self.udtName = udtName
        self.isNullable = isNullable
    }

    public let name: String
    public let udtName: String
    public let isNullable: Bool
    
    // https://www.postgresql.org/docs/9.5/datatype.html
    // https://github.com/SweetIQ/schemats/blob/master/src/schemaPostgres.ts#L17-L93
    public var swiftType: String {
        switch udtName {
        case "bpchar", "char", "varchar", "text", "citext", "bytea", "inet", "time", "timetz", "interval", "name":
            return "String"
        case "uuid":
            return "UUID"
        case "int2", "int4", "int8":
            return "Int"
        case "float4", "float8":
            return "Double"
        case "bool":
            return "Bool"
        case "date", "timestamp", "timestamptz":
            return "Date"
        case "_int2", "_int4", "_int8":
            return "[Int]"
        case "_float4", "_float8":
            return "[Double]"
        case "_bool":
            return "[Bool]"
        case "_varchar", "_text", "_citext", "_bytea":
            return "[String]"
        case "_uuid":
            return "[UUID]"
        case "_timestamptz":
            return "[Date]"
        case "numeric", "money", "_numeric", "_money", "oid", "json", "jsonb", "_json", "_jsonb":
            fallthrough
        default:
            return "Any! \\\\Unknown postgres type: \(udtName)"
        }
    }
}
