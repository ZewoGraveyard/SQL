//
//  Row.swift
//  SQL
//
//  Created by David Ask on 08/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//


public protocol Row {
    typealias ValueType: Value
    
    init(valuesByName: [String: ValueType])
    
    var valuesByName: [String: ValueType] { get }
    
    subscript(fieldName: String) -> ValueType? { get }
}

public extension Row {
    public subscript(fieldName: String) -> ValueType? {
        return valuesByName[fieldName]
    }
}