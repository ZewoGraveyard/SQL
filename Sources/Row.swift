//
//  Row.swift
//  SwiftSQL
//
//  Created by David Ask on 08/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//



public protocol RowValue : CustomStringConvertible {
    var stringValue: String? { get }
    
    var integerValue: Int? { get }
    
    var doubleValue: Double? { get }
}

public extension RowValue {
    public var description: String {
        guard let string = stringValue else {
            return "<<non-string representable>>"
        }
        
        return string
    }
}

public protocol Row : CustomStringConvertible {
    typealias RowValueType : RowValue
    
    subscript(fieldName: String) -> RowValueType? { get }
}