//
//  Parameter.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//

public struct Join {
    public enum `Type` {
        case inner(SQLComponent)
        case outer(SQLComponent)
    }
    
    public let leftKey: SQLComponent
    public let rightKey: SQLComponent
    public let type: Type
    
    public init(type: `Type`, leftKey: SQLComponent, rightKey: SQLComponent) {
        self.type = type
        self.leftKey = leftKey
        self.rightKey = rightKey
    }
}

extension Join: SQLComponent {
    public var sqlString: String {
        return [
                type,
                "ON",
                leftKey,
                "=",
                rightKey
                   ]
            .sqlStringJoined(separator: " ")
    }
}

extension Join.`Type`: SQLComponent {
    public var sqlString: String {
        switch self {
        case .inner(let table):
            return "INNER JOIN \(table.sqlString)"
        case .outer(let table):
            return "OUTER JOIN \(table.sqlString)"
        }
    }
}