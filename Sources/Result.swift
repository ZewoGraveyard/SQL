//
//  Result.swift
//  SQL
//
//  Created by David Ask on 08/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//


public protocol ResultStatus {
    var successful: Bool { get }
}

public protocol Result: CollectionType {
    typealias FieldType: Field
    typealias RowType: Row
    
    func clear()
    
    var fields: [FieldType] { get }
    
    subscript(position: Index) -> RowType { get }
}

public extension Result {
    public var startIndex: Self.Index.Distance {
        return 0
    }
    
    public var endIndex: Self.Index.Distance {
        return count
    }
}
