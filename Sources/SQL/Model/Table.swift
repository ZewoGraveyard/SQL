//
//  Table.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//


public protocol Table {
    associatedtype Field: RawRepresentable, Hashable
    static var tableName: String { get }
}

public extension Table where Self.Field.RawValue == String {
    public static func field(_ field: Field) -> QualifiedField {
        return QualifiedField("\(self.tableName).\(field.rawValue)")
    }
    
    public static func select(_ fields: Field...) -> Select {
        return Select(fields.map { field($0).alias("\(self.tableName)__\($0.rawValue)") }, from: [tableName])
    }
    
    public static func select() -> Select {
        return Select("*", from: tableName)
    }
 
    public static func update(_ dict: [Field: ValueConvertible?]) -> Update {
        var translated = [QualifiedField: ValueConvertible?]()
        
        for (key, value) in dict {
            translated[field(key)] = value
        }
        
        return Update(tableName).set(translated)
    }
    
    public static func insert(_ dict: [Field: ValueConvertible?]) -> Insert {
        var translated = [QualifiedField: ValueConvertible?]()
        
        for (key, value) in dict {
            translated[field(key)] = value
        }
        
        return Insert(tableName, values: translated)
    }
    
    public static func delete(where predicate: Predicate) -> Delete {
        return Delete(from: tableName).filter(predicate)
    }
    
    public static func delete() -> Delete {
        return Delete(from: tableName)
    }
}