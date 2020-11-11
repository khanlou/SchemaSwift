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
        case "bpchar":
        case "char":
        case "varchar":
        case "text":
        case "citext":
        case "bytea":
        case "inet":
        case "time":
        case "timetz":
        case "interval":
        case "name":
            return "String"
        case "uuid":
            return "UUID"
        case "int2":
        case "int4":
        case "int8":
            return "Int"
        case "float4":
        case "float8":
            return "Double"
        case "bool":
            return "Bool"
        case "date":
        case "timestamp":
        case "timestamptz":
            return "Date"
        case "_int2":
        case "_int4":
        case "_int8":
            return "[Int]"
        case "_float4":
        case "_float8":
            return "[Double]"
        case "_bool":
            return "[Bool]"
        case "_varchar":
        case "_text":
        case "_citext":
        case "_bytea":
            return "[String]"
        case "_uuid":
            return "[UUID]"
        case "_timestamptz":
            return "[Date]"
        case "numeric":
        case "money":
        case "_numeric":
        case "_money":
        case "oid":
        case "json":
        case "jsonb":
        case "_json":
        case "_jsonb":
        default:
            return "Any! \\Unknown postgres type: \(udtName)"
        }
    }
}
