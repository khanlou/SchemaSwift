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



    public var swiftType: String {
        switch udtName {
        case "text":
            return "String"
        case "int4":
            return "Int"
        case "uuid":
            return "UUID"
        case "timestamptz":
            return "Date"
        case "bool":
            return "Bool"
        default:
            return "Unknown! \\ postgres type: \(udtName)"
        }
    }
}
