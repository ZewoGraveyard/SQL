//
//  Update.swift
//  SQL
//
//  Created by David Ask on 26/05/16.
//
//

public class Update: PredicatedQuery {
    public var predicate: Predicate? = nil
    
    internal var valuesByField: [QualifiedField: Value?]
    
    public let tableName: String
    
    public init(_ tableName: String, values: [QualifiedField: Value?]) {
        self.tableName = tableName
        self.valuesByField = values
    }
}
