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
        let fields: [SQLStringRepresentable] = fields.map { self.field($0) }
        return Select(fields, from: [tableName])
    }
    
    public static func select(top: Select.Top, _ fields: Field...) -> Select {
        let fields: [SQLStringRepresentable] = fields.map { self.field($0) }
        return Select(top: top, fields, from: [tableName])
    }
}