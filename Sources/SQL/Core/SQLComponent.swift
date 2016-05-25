//
//  Query.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//


public protocol SQLComponent: CustomStringConvertible {
    var sqlString: String { get }
    var sqlParameters: [Value?] { get }
}

extension SQLComponent {
    public var description: String {
        return sqlString
    }
}

public extension SQLComponent {
    var sqlParameters: [Value?] {
        return []
    }
}

extension String: SQLComponent {
    public var sqlString: String {
        return self
    }
}

public extension Sequence where Iterator.Element: SQLComponent {
    public func sqlStringJoined(separator: String? = nil, isolate: Bool = false) -> String {
        return map { $0 as SQLComponent }.sqlStringJoined(separator: separator, isolate: isolate)
    }
    
    public var sqlParameters: [Value?] {
        return map { $0 as SQLComponent }.sqlParameters
    }
}

public extension Sequence where Iterator.Element == SQLComponent {
    public func sqlStringJoined(separator: String? = nil, isolate: Bool = false) -> String {
        let string = map { $0.sqlString }.joined(separator: separator ?? "")
        
        if(isolate) {
            return "(\(string))"
        }
        
        return string
    }
    
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
