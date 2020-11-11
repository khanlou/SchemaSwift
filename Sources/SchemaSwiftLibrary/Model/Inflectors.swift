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
        Pluralizer.shared.singularize(string: original)
    }

    public static func pluralize(_ original: String) -> String {
        Pluralizer.shared.pluralize(string: original)
    }
}

// pulled from https://github.com/draveness/RbSwift/blob/f4492d4dfbd5ecc6b299e424bfd7f36aa619098c/RbSwift/Inflector/Inflector.swift
struct InflectorRule {
    var rule: String
    var replacement: String
    let regex: NSRegularExpression

    init(rule: String, replacement: String) {
        self.rule = rule
        self.replacement = replacement
        self.regex = try! NSRegularExpression(pattern: rule, options: .caseInsensitive)
    }
}

class Pluralizer {

    static let shared = Pluralizer()

    private let pluralRules: [InflectorRule]
    private let singularRules: [InflectorRule]
    private let words: Set<String>

    init() {

        let uncountables = ["access", "accommodation", "adulthood", "advertising", "advice", "aggression", "aid", "air", "alcohol", "anger", "applause", "arithmetic", "art", "assistance", "athletics", "attention", "bacon", "baggage", "ballet", "beauty", "beef", "beer", "biology", "botany", "bread", "butter", "carbon", "cash", "chaos", "cheese", "chess", "childhood", "clothing", "coal", "coffee", "commerce", "compassion", "comprehension", "content", "corruption", "cotton", "courage", "cream", "currency", "dancing", "danger", "data", "delight", "dignity", "dirt", "distribution", "dust", "economics", "education", "electricity", "employment", "engineering", "envy", "equipment", "ethics", "evidence", "evolution", "faith", "fame", "fish", "flour", "flu", "food", "freedom", "fuel", "fun", "furniture", "garbage", "garlic", "genetics", "gold", "golf", "gossip", "grammar", "gratitude", "grief", "ground", "guilt", "gymnastics", "hair", "happiness", "hardware", "harm", "hate", "hatred", "health", "heat", "height", "help", "homework", "honesty", "honey", "hospitality", "housework", "humour", "hunger", "hydrogen", "ice", "importance", "inflation", "information", "injustice", "innocence", "iron", "irony", "jealousy", "jeans", "jelly", "judo", "karate", "kindness", "knowledge", "labour", "lack", "laughter", "lava", "leather", "leisure", "lightning", "linguistics", "litter", "livestock", "logic", "loneliness", "luck", "luggage", "machinery", "magic", "management", "mankind", "marble", "mathematics", "mayonnaise", "measles", "meat", "methane", "milk", "money", "mud", "music", "nature", "news", "nitrogen", "nonsense", "nurture", "nutrition", "obedience", "obesity", "oil", "oxygen", "passion", "pasta", "patience", "permission", "physics", "poetry", "police", "pollution", "poverty", "power", "pronunciation", "psychology", "publicity", "quartz", "racism", "rain", "relaxation", "reliability", "research", "respect", "revenge", "rice", "rubbish", "rum", "salad", "satire", "seaside", "series", "shame", "sheep", "shopping", "silence", "sleep", "smoke", "smoking", "snow", "soap", "software", "soil", "sorrow", "soup", "species", "speed", "spelling", "steam", "stuff", "stupidity", "sunshine", "symmetry", "tennis", "thirst", "thunder", "toast", "tolerance", "toys", "traffic", "transporation", "travel", "trust", "understanding", "unemployment", "unity", "validity", "veal", "vengeance", "violence"]

        let singularToPlural = [
            "$": "s",
            "s$": "s",
            "^(ax|test)is$": "$1es",
            "(octop|vir)us$": "$1i",
            "(octop|vir)i$": "$1i",
            "(alias|status)$": "$1es",
            "(bu)s$": "$1ses",
            "(buffal|tomat)o$": "$1oes",
            "([ti])um$": "$1a",
            "([ti])a$": "$1a",
            "sis$": "ses",
            "(?:([^f])fe|([lr])f)$": "$1$2ves",
            "(hive)$": "$1s",
            "([^aeiouy]|qu)y$": "$1ies",
            "(x|ch|ss|sh)$": "$1es",
            "(matr|vert|ind)(?:ix|ex)$": "$1ices",
            "^(m|l)ouse$": "$1ice",
            "^(m|l)ice$": "$1ice",
            "^(ox)$": "$1en",
            "^(oxen)$": "$1",
            "(quiz)$": "$1zes",
        ]

        let pluralToSingular = [
            "s$": "",
            "(ss)$": "$1",
            "(n)ews$": "$1ews",
            "([ti])a$": "$1um",
            "((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)(sis|ses)$": "$1sis",
            "(^analy)(sis|ses)$": "$1sis",
            "([^f])ves$": "$1fe",
            "(hive)s$": "$1",
            "(tive)s$": "$1",
            "([lr])ves$": "$1f",
            "([^aeiouy]|qu)ies$": "$1y",
            "(s)eries$": "$1eries",
            "(m)ovies$": "$1ovie",
            "(x|ch|ss|sh)es$": "$1",
            "^(m|l)ice$": "$1ouse",
            "(bus)(es)?$": "$1",
            "(o)es$": "$1",
            "(shoe)s$": "$1",
            "(cris|test)(is|es)$": "$1is",
            "^(a)x[ie]s$": "$1xis",
            "(octop|vir)(us|i)$": "$1us",
            "(alias|status)(es)?$": "$1",
            "^(ox)en": "$1",
            "(vert|ind)ices$": "$1ex",
            "(matr)ices$": "$1ix",
            "(quiz)zes$": "$1",
            "(database)s$": "$1",
        ]

        let unchangings = [
            "sheep",
            "deer",
            "moose",
            "swine",
            "bison",
            "corps",
            "means",
            "series",
            "scissors",
            "species",
        ]

        let irregulars = [
            "person": "people",
            "man": "men",
            "child": "children",
            "sex": "sexes",
            "move": "moves",
            "zombie": "zombies",
        ]

        var pluralRules: [InflectorRule] = []
        var singularRules: [InflectorRule] = []
        var words: Set<String> = Set<String>()

        func addIrregularRule(singular: String, andPlural plural: String) {
            let singularRule: String = "\(plural)$"
            addSingularRule(rule: singularRule, forReplacement: singular)
            let pluralRule: String = "\(singular)$"
            addPluralRule(rule: pluralRule, forReplacement: plural)
        }

        func addSingularRule(rule: String, forReplacement replacement: String) {
            singularRules.append(InflectorRule(rule: rule, replacement: replacement))
        }

        func addPluralRule(rule: String, forReplacement replacement: String) {
            pluralRules.append(InflectorRule(rule: rule, replacement: replacement))
        }

        irregulars.forEach { (key, value) in
            addIrregularRule(singular: key, andPlural: value)
        }

        singularToPlural.reversed().forEach { (key, value) in
            addPluralRule(rule: key, forReplacement: value)
        }

        pluralToSingular.reversed().forEach { (key, value) in
            addSingularRule(rule: key, forReplacement: value)
        }

        unchangings.forEach { words.insert($0) }
        uncountables.forEach { words.insert($0) }

        self.pluralRules = pluralRules
        self.singularRules = singularRules
        self.words = words
    }

    func pluralize(string: String) -> String {
        return apply(rules: pluralRules, forString: string)
    }

    func singularize(string: String) -> String {
        return apply(rules: singularRules, forString: string)
    }

    private func apply(rules: [InflectorRule], forString string: String) -> String {
        guard !words.contains(string) else {
            return string
        }

        let range = NSMakeRange(0, string.utf16.count)

        let matchingRule = rules.first(where: { $0.regex.firstMatch(in: string, range: range) != nil })

        if let matchingRule = matchingRule {
            return matchingRule.regex.stringByReplacingMatches(in: string, range: range, withTemplate: matchingRule.replacement)
        } else {
            return string
        }
    }
}
