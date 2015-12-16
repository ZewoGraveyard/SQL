//
//  SQLParameterConvertible.swift
//  SQL
//
//  Created by David Ask on 16/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//

import Foundation

public enum SQLParameterConvertibleType {
    case Binary([UInt8])
    case Text(String)
}

public protocol SQLParameterConvertible {
    var SQLParameterData: SQLParameterConvertibleType { get }
}

extension Int: SQLParameterConvertible {}
extension Double: SQLParameterConvertible {}
extension Float: SQLParameterConvertible {}

extension String: SQLParameterConvertible {
    public var SQLParameterData: SQLParameterConvertibleType {
        return .Text(self)
    }
}

public extension SQLParameterConvertible where Self: CustomStringConvertible {
    public var SQLParameterData: SQLParameterConvertibleType {
        return .Text(self.description)
    }
}

extension NSData: SQLParameterConvertible {
    public var SQLParameterData: SQLParameterConvertibleType {
        
        var a = [UInt8](count: length / sizeof(UInt8), repeatedValue: 0)
        getBytes(&a, length: length)
        
        return .Binary(a)
    }
}