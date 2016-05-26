//
//  Composer.swift
//  SQL
//
//  Created by David Ask on 26/05/16.
//
//

public protocol QueryComposer {
    static func composeStatement(_ select: Select) -> String   
}

public extension QueryComposer {
    static func composePredicate(_ predicate: Predicate) -> String {
        switch predicate {
        case .expression(let left, let op, let right):
            var components = [composeParameter(left), op.sqlString]
            
            switch op {
            case .containedIn, .contains:
                components.append("(\(composeParameter(right)))")
                break
            default:
                components.append(composeParameter(right))
            }
            
            return components.joined(separator: " ")
            
        case .and(let predicates):
            return "(\(predicates.map { composePredicate($0) }.joined(separator: " AND ")))"
        case .or(let predicates):
            return "(\(predicates.map { composePredicate($0) }.joined(separator: " OR ")))"
        case .not(let predicate):
            return "NOT \(composePredicate(predicate))"
        }
    }
    
    static func composeParameter(_ parameter: Parameter) -> String {
        switch parameter {
        case .field(let field):
            return field.sqlString
        case .function(let function):
            return function.sqlString
        case .query(let select):
            return composeStatement(select)
        case .value:
            return "%@"
        case .values(let values):
            return values.map { _ in "%@" }.joined(separator: ", ")
        }
    }
}

