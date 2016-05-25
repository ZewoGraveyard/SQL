//
//  Parameter.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//

public enum Parameter {
    
    case field(QualifiedField)
    case value(Value?)
    case subquery(Select)
    case function(Function)
}

extension Parameter: SQLStringRepresentable {
    public var sqlString: String {
        switch self {
        case .field(let field):
            return field.sqlString
        case .value:
            return "%@"
        case .subquery(let query):
            return query.sqlString
        case .function(let function):
            return function.sqlString
        }
    }
    
    public var sqlParameters: [Value?] {
        switch self {
        case .field(let field):
            return field.sqlParameters
        case .value(let value):
            return [value]
        case .subquery(let query):
            return query.sqlParameters
        case .function(let function):
            return function.sqlParameters
        }
    }
}
