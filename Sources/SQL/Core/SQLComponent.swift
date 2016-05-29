//
//  Query.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//

public protocol SQLStatementStringConvertible: CustomStringConvertible {
    var sqlString: String { get }
}

extension SQLStatementStringConvertible {
    public var description: String {
        return sqlString
    }
}

public extension String {
    public func sqlStringWithEscapedPlaceholdersUsingPrefix(_ prefix: String, suffix: String? = nil, transformer: (Int) -> String) -> String {
        
        var strings = split(byString: "%@")
        
        if strings.count == 1 {
            return self
        }
        
        var newStrings = [String]()
        
        for i in 0..<strings.count - 1 {
            newStrings.append(strings[i])
            newStrings.append(prefix)
            newStrings.append(transformer(i))
            
            if let suffix = suffix {
                newStrings.append(suffix)
            }
        }
        
        newStrings.append(strings.last!)
        
        return newStrings.joined(separator: "")
    }
}


public protocol SQLStatementParameterListConvertible {
    var sqlParameters: [Value?] { get }
}

public extension Sequence where Iterator.Element: SQLStatementStringConvertible {
    public func sqlStringJoined(separator: String? = nil, isolate: Bool = false) -> String {
        return map { $0 as SQLStatementStringConvertible }.sqlStringJoined(separator: separator, isolate: isolate)
    }
}

public extension Sequence where Iterator.Element == SQLStatementStringConvertible {
    public func sqlStringJoined(separator: String? = nil, isolate: Bool = false) -> String {
        let string = map { $0.sqlString }.joined(separator: separator ?? "")
        
        if(isolate) {
            return "(\(string))"
        }
        
        return string
    }
}

public extension Sequence where Iterator.Element: SQLStatementParameterListConvertible {
    public var sqlParameters: [Value?] {
        return map { $0 as SQLStatementParameterListConvertible }.sqlParameters
    }
}

public extension Sequence where Iterator.Element == SQLStatementParameterListConvertible {
    public var sqlParameters: [Value?] {
        return flatMap { $0.sqlParameters }
    }
}
