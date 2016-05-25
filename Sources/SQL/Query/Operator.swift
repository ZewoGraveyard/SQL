//
//  Parameter.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//

public enum Operator {
    case equal
    
    case greaterThan
    case greaterThanOrEqual
    
    case lessThan
    case lessThanOrEqual
}

extension Operator: SQLStringRepresentable {
    public var sqlString: String {
        switch self {
        case .equal:
            return "="
        case .greaterThan:
            return ">"
        case .greaterThanOrEqual:
            return ">="
        case .lessThan:
            return "<"
        case .lessThanOrEqual:
            return "<="
        }
    }
}