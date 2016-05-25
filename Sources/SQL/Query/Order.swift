//
//  Parameter.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//


public enum Order {
    case asc(SQLComponent)
    case desc(SQLComponent)
}

extension Order: SQLComponent {
    public var sqlString: String {
        switch self {
        case .asc(let representable):
            return "\(representable.sqlString) ASC"
        case .desc(let representable):
            return "\(representable.sqlString) DESC"
        }
    }
}