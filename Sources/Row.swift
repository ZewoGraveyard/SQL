//
//  Row.swift
//  SQL
//
//  Created by David Ask on 08/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//



public protocol RowValue : CustomStringConvertible {
    var string: String? { get }
    
    var integer: Int? { get }
    
    var double: Double? { get }
    
    var float: Float? { get }
}

public extension RowValue {
    public var description: String {
        guard let string = string else {
            return "<<non-string representable>>"
        }

        
        return string
    }
}

public protocol Row {
    typealias RowValueType : RowValue
    
    subscript(fieldName: String) -> RowValueType? { get }
}
