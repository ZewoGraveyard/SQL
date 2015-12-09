//
//  Query.swift
//  SwiftSQL
//
//  Created by David Ask on 08/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//


public struct Query : StringLiteralConvertible, CustomStringConvertible {
    public var string: String
    
    public init(string: String) {
        self.string = string
    }
    
    public init(stringLiteral value: String) {
        self.init(string: value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(string: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(string: value)
    }
    
    public var description: String {
        return string
    }
}