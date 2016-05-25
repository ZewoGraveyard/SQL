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

extension Function: SQLStringRepresentable {
    public var sqlString: String {
        switch self {
        case .sum(let field):
            return "sum(\(field.sqlString))"
        }
    }
}
