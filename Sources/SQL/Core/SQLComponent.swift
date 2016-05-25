//
//  Query.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//

public protocol SQLStringRepresentable {
    var sqlString: String { get }
}

extension SQLStringRepresentable {
    public var description: String {
        return sqlString
    }

    public func sqlStringWithEscapedPlaceholdersUsingPrefix(_ prefix: String, suffix: String? = nil, transformer: (Int) -> String) -> String {
        
        var strings = sqlString.split(byString: "%@")
        
        if strings.count == 1 {
            return sqlString
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

extension String: SQLStringRepresentable {
    public var sqlString: String {
        return self
    }
}

public protocol SQLPrametersRepresentable {
    var sqlParameters: [Value?] { get }
}


public protocol SQLComponent: SQLStringRepresentable, SQLPrametersRepresentable, CustomStringConvertible {
    
    
}


public extension Sequence where Iterator.Element: SQLStringRepresentable {
    public func sqlStringJoined(separator: String? = nil, isolate: Bool = false) -> String {
        return map { $0 as SQLStringRepresentable }.sqlStringJoined(separator: separator, isolate: isolate)
    }
}

public extension Sequence where Iterator.Element == SQLStringRepresentable {
    public func sqlStringJoined(separator: String? = nil, isolate: Bool = false) -> String {
        let string = map { $0.sqlString }.joined(separator: separator ?? "")
        
        if(isolate) {
            return "(\(string))"
        }
        
        return string
    }
}

public extension Sequence where Iterator.Element: SQLPrametersRepresentable {
    public var sqlParameters: [Value?] {
        return map { $0 as SQLPrametersRepresentable }.sqlParameters
    }
}

public extension Sequence where Iterator.Element == SQLPrametersRepresentable {

    public var sqlParameters: [Value?] {
        return flatMap { $0.sqlParameters }
    }
}

//
//public struct SQLArray: SQL {
//    public let representables: [SQL]
//    public var separator: String?
//    public var isolated: Bool = false
//    
//    public var sqlString: String {
//        let str = representables.map { $0.sqlString }.joined(separator: separator ?? "")
//        
//        if(isolated) {
//            return "(\(str))"
//        }
//        
//        return str
//    }
//    
//    public func isolateInPlace() -> SQLArray {
//        var new = self
//        new.isolate()
//        return new
//    }
//    
//    public mutating func isolate() {
//        isolated = true
//    }
//    
//    public var sqlParameters: [Value?] {
//        return representables.flatMap { $0.sqlParameters }
//    }
//    
//    public init(_ representables: [SQL], separator: String? = nil) {
//        self.representables = representables
//        self.separator = separator
//    }
//
//}
