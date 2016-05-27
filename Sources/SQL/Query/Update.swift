//
//  Update.swift
//  SQL
//
//  Created by David Ask on 26/05/16.
//
//

public class Update: PredicatedQuery {
    public var predicate: Predicate? = nil
    
    public private(set) var valuesByField: [QualifiedField: Value?] = [:]
    
    public let tableName: String
    
    public init(_ tableName: String) {
        self.tableName = tableName
    }
    
    public func set<T: ValueConvertible>(_ field: QualifiedField, _ value: T?) -> Update {
        valuesByField[field] = value?.sqlValue
        return self
    }
    
    public func set(_ dict: [QualifiedField: ValueConvertible?]) -> Update {
        for (key, value) in dict {
            valuesByField[key] = value?.sqlValue
        }
        return self
    }
}

extension Update: SQLPrametersRepresentable {
    public var sqlParameters: [Value?] {
        var parameters = [Value?]()
        
        if let predicate = predicate {
            parameters += predicate.sqlParameters
        }
        
        parameters += valuesByField.values
        
        return parameters
    }
}
