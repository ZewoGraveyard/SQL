//
//  Parameter.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//

public struct Join {
    public enum `Type` {
        case inner(SQLStringRepresentable)
        case outer(SQLStringRepresentable)
    }
    
    public let leftKey: SQLStringRepresentable
    public let rightKey: SQLStringRepresentable
    public let type: Type
    
    public init(type: `Type`, leftKey: SQLStringRepresentable, rightKey: SQLStringRepresentable) {
        self.type = type
        self.leftKey = leftKey
        self.rightKey = rightKey
    }
}

extension Join: SQLStringRepresentable {
    public var sqlString: String {
        return "\(type.sqlString) ON \(leftKey.sqlString) = \(rightKey.sqlString)"
    }
}

extension Join.`Type`: SQLStringRepresentable {
    public var sqlString: String {
        switch self {
        case .inner(let table):
            return "INNER JOIN \(table.sqlString)"
        case .outer(let table):
            return "OUTER JOIN \(table.sqlString)"
        }
    }
}