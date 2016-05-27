//
//  Delete.swift
//  SQL
//
//  Created by David Ask on 27/05/16.
//
//

public class Delete: PredicatedQuery {
    public var predicate: Predicate? = nil
    
    public let tableName: String
    
    public init(from tableName: String) {
        self.tableName = tableName
    }
}

extension Delete: SQLPrametersRepresentable {
    public var sqlParameters: [Value?] {
        if let predicate = predicate {
            return predicate.sqlParameters
        }
        
        return []
    }
}