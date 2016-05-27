//
//  Insert.swift
//  SQL
//
//  Created by David Ask on 27/05/16.
//
//

public class Insert {
    public let valuesByField: [QualifiedField: Value?]
    
    public let tableName: String
    
    public private(set) var returning: [QualifiedField]?
    
    public init(_ tableName: String, values: [QualifiedField: Value?]) {
        self.tableName = tableName
        self.valuesByField = values
    }
    
    public convenience init(_ tableName: String, values: [QualifiedField: ValueConvertible?]) {
        var transformed = [QualifiedField: Value?]()
        
        for (key, value) in values {
            transformed[key] = value?.sqlValue
        }
        
        self.init(tableName, values: transformed)
    }
    
    public func returning(_ fields: [QualifiedField]) -> Insert {
        var new = returning ?? []
        new += fields
        returning = new
        return self
    }
    
    public func returning(_ fields: QualifiedField...) -> Insert {
        return returning(fields)
    }
}

extension Insert: SQLPrametersRepresentable {
    public var sqlParameters: [Value?] {
        return Array(valuesByField.values)
    }
}
