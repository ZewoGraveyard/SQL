//
//  Field.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//


public struct QualifiedField {
    public let unqualifiedName: String
    public var tableName: String?
    
    public init(_ name: String) {
        let components = name.split(separator: ".")
        if components.count == 2, let tableName = components.first, let fieldName = components.last {
            self.unqualifiedName = fieldName
            self.tableName = tableName
        }
        else {
            self.unqualifiedName = name
            self.tableName = nil
        }
    }
}

public extension QualifiedField {
    public var qualifiedName: String {
        guard let tableName = tableName else {
            return unqualifiedName
        }
        return tableName + "." + unqualifiedName
    }
    
    public var alias: String {
        guard let tableName = tableName else {
            return unqualifiedName
        }
        return tableName + "__" + unqualifiedName
    }
}

extension QualifiedField: SQLStringRepresentable {
    public var sqlString: String {
        return qualifiedName
    }
}

extension QualifiedField: SelectReference {
    public var selectReference: Select.Reference {
        return .string(qualifiedName)
    }
}

//prefix operator % {}
//public prefix func % (_ name: String) -> QualifiedField {
//    return QualifiedField(name)
//}
//
