//
//  Parameter.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//

public enum Operator {
    case equal
}

extension Operator: SQLComponent {
    public var sqlString: String {
        switch self {
        case .equal:
            return "="
        }
    }
}