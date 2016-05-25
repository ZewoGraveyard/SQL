//
//  Parameter.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//

public indirect enum Predicate {
    case expression(left: Parameter, operator: Operator, right: Parameter)
    case and([Predicate])
    case or([Predicate])
    case not(Predicate)
    case boolean(Bool)
}

extension Predicate: SQLComponent {
    public var sqlString: String {
        switch self {
        case .expression(let left, let op, let right):
            return "\(left.sqlString) \(op.sqlString) \(right.sqlString)"
        case .and(let predicates):
            return predicates.sqlStringJoined(separator: " AND ", isolate: true)
        case .or(let predicates):
            return predicates.sqlStringJoined(separator: " OR ", isolate: true)
        case .not(let predicate):
            return "NOT \(predicate.sqlString)"
        case .boolean(let bool):
            return bool ? "1" : "0"
        }
    }
    
    public var sqlParameters: [Value?] {
        switch self {
        case .expression(let left, _, let right):
            return left.sqlParameters + right.sqlParameters
        case .and(let predicates):
            return predicates.flatMap { $0.sqlParameters }
        case .or(let predicates):
            return predicates.flatMap { $0.sqlParameters }
        case .not(let predicate):
            return predicate.sqlParameters
        case .boolean:
            return []
        }
    }
}

public prefix func ! (predicate: Predicate) -> Predicate {
    return .not(predicate)
}

// MARK: Equal operator

// QualifiedField

public func == (lhs: QualifiedField, rhs: QualifiedField) -> Predicate {
    return .expression(left: .field(lhs), operator: .equal, right: .field(rhs))
}

public func == <T: ValueConvertible>(lhs: QualifiedField, rhs: T) -> Predicate {
    return .expression(left: .field(lhs), operator: .equal, right: .value(rhs.sqlValue))
}

// String

public func == (lhs: String, rhs: QualifiedField) -> Predicate {
    return .expression(left: .field(QualifiedField(lhs)), operator: .equal, right: .field(rhs))
}

public func == <T: ValueConvertible>(lhs: String, rhs: T) -> Predicate {
    return .expression(left: .field(QualifiedField(lhs)), operator: .equal, right: .value(rhs.sqlValue))
}

// Function

public func == (lhs: Function, rhs: QualifiedField) -> Predicate {
    return .expression(left: .function(lhs), operator: .equal, right: .field(rhs))
}

public func == <T: ValueConvertible>(lhs: Function, rhs: T) -> Predicate {
    return .expression(left: .function(lhs), operator: .equal, right: .value(rhs.sqlValue))
}

// MARK: GreaterThan operator

// QualifiedField

public func > (lhs: QualifiedField, rhs: QualifiedField) -> Predicate {
    return .expression(left: .field(lhs), operator: .equal, right: .field(rhs))
}

public func > <T: ValueConvertible>(lhs: QualifiedField, rhs: T) -> Predicate {
    return .expression(left: .field(lhs), operator: .equal, right: .value(rhs.sqlValue))
}

// String

public func > (lhs: String, rhs: QualifiedField) -> Predicate {
    return .expression(left: .field(QualifiedField(lhs)), operator: .equal, right: .field(rhs))
}

public func > <T: ValueConvertible>(lhs: String, rhs: T) -> Predicate {
    return .expression(left: .field(QualifiedField(lhs)), operator: .equal, right: .value(rhs.sqlValue))
}

// Function

public func > (lhs: Function, rhs: QualifiedField) -> Predicate {
    return .expression(left: .function(lhs), operator: .equal, right: .field(rhs))
}

public func > <T: ValueConvertible>(lhs: Function, rhs: T) -> Predicate {
    return .expression(left: .function(lhs), operator: .equal, right: .value(rhs.sqlValue))
}



// MARK: Compound predicate

public func && (lhs: Predicate, rhs: Predicate) -> Predicate {
    return .and([lhs, rhs])
}

public func || (lhs: Predicate, rhs: Predicate) -> Predicate {
    return .or([lhs, rhs])
}

// Predicated query

public protocol PredicatedQuery: class {
    var predicate: Predicate? { get set }
}

public extension PredicatedQuery {
    public func filter(_ value: Predicate) -> Self {
        guard let existing = predicate else {
            predicate = value
            return self
        }
        
        predicate = .and([existing, value])
        return self
    }
}