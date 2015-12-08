//
//  Row.swift
//  SwiftSQL
//
//  Created by David Ask on 08/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//


public protocol RowSet : CollectionType {
    
}

public protocol Row {
    typealias ValueType
    
    subscript(fieldName: String) -> ValueType { get }
}