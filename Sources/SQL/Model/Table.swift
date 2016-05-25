//
//  Table.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//

public protocol Table {
    associatedtype Field: RawRepresentable
    static var tableName: String { get }
}

public extension Table where Self.Field.RawValue == String {
    public static func field(_ field: Field) -> QualifiedField {
        return QualifiedField("\(self.tableName).\(field.rawValue)")
    }
    
    public static func select(_ fields: Field...) -> Select {
        return Select(fields.map { field($0) }, from: [tableName])
    }
 
}