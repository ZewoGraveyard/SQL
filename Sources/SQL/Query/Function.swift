//
//  Function.swift
//  SQL
//
//  Created by David Ask on 24/05/16.
//
//

public enum Function {
    case sum(QualifiedField)
}

extension Function: SQLComponent {
    public var sqlString: String {
        switch self {
        case .sum(let field):
            return "sum(\(field.sqlString))"
        }
    }
    
    public var sqlParameters: [Value?] {
        switch self {
        case .sum(let field):
            return field.sqlParameters
        }
    }
}
