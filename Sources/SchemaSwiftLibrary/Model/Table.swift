//
//  Table.swift
//  
//
//  Created by Soroush Khanlou on 11/1/20.
//

import Foundation

public struct TableDefinition {
    public let name: String
    public let columns: [Column]
    
    public init(name: String, columns: [Column]) {
        self.name = name
        self.columns = columns
    }
}

