//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 11/1/20.
//

import Foundation

public enum Inflections {
    public static func upperCamelCase(_ stringKey: String) -> String {
        camelCase(stringKey, uppercaseFirstLetter: true)
    }

    public static func lowerCamelCase(_ stringKey: String) -> String {
        camelCase(stringKey, uppercaseFirstLetter: false)
    }

    // pulled from https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/Foundation/JSONEncoder.swift#L1061-L1105
    static func camelCase(_ stringKey: String, uppercaseFirstLetter: Bool) -> String {
        guard !stringKey.isEmpty else { return stringKey }

        // Find the first non-underscore character
        guard let firstNonUnderscore = stringKey.firstIndex(where: { $0 != "_" }) else {
            // Reached the end without finding an _
            return stringKey
        }

        // Find the last non-underscore character
        var lastNonUnderscore = stringKey.index(before: stringKey.endIndex)
        while lastNonUnderscore > firstNonUnderscore && stringKey[lastNonUnderscore] == "_" {
            stringKey.formIndex(before: &lastNonUnderscore)
        }

        let keyRange = firstNonUnderscore...lastNonUnderscore
        let leadingUnderscoreRange = stringKey.startIndex..<firstNonUnderscore
        let trailingUnderscoreRange = stringKey.index(after: lastNonUnderscore)..<stringKey.endIndex

        let components = stringKey[keyRange].split(separator: "_")
        let joinedString : String
        if components.count == 1 {
            // No underscores in key, leave the word as is - maybe already camel cased
            if uppercaseFirstLetter {
                joinedString = String(stringKey[keyRange]).capitalized
            } else {
                joinedString = String(stringKey[keyRange])
            }
        } else {
            if uppercaseFirstLetter {
                joinedString = components.map({ $0.capitalized }).joined()
            } else {
                joinedString = ([components[0].lowercased()] + components[1...].map { $0.capitalized }).joined()
            }
        }

        // Do a cheap isEmpty check before creating and appending potentially empty strings
        let result : String
        if (leadingUnderscoreRange.isEmpty && trailingUnderscoreRange.isEmpty) {
            result = joinedString
        } else if (!leadingUnderscoreRange.isEmpty && !trailingUnderscoreRange.isEmpty) {
            // Both leading and trailing underscores
            result = String(stringKey[leadingUnderscoreRange]) + joinedString + String(stringKey[trailingUnderscoreRange])
        } else if (!leadingUnderscoreRange.isEmpty) {
            // Just leading
            result = String(stringKey[leadingUnderscoreRange]) + joinedString
        } else {
            // Just trailing
            result = joinedString + String(stringKey[trailingUnderscoreRange])
        }
        return result
    }

    public static func singularize(_ original: String) -> String {
        if original.last == "s" {
            return String(original.dropLast())
        }
        return original
    }
}
