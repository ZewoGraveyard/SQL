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
    case function(Function)
}

extension Parameter: SQLComponent {
    public var sqlString: String {
        switch self {
        case .field(let field):
            return field.sqlString
        case .value:
            return "%@"
        case .function(let function):
            return function.sqlString
        }
    }
    
    public var sqlParameters: [Value?] {
        switch self {
        case .field:
            return []
        case .value(let value):
            return [value]
        case .function:
            return []
        }
    }
}
