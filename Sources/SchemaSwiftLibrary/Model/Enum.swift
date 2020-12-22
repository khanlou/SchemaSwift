//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 12/21/20.
//

import Foundation

public struct EnumDefinition {

    public let name: String
    public let values: [String]

    public init(name: String, values: [String]) {
        self.name = name
        self.values = values
    }
}
