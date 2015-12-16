//
//  Value.swift
//  SQL
//
//  Created by David Ask on 10/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//


import Core

public protocol Value: CustomStringConvertible {
    
    var data: Data { get }
    
    init(data: Data)
}

extension Value {
    public var float: Float? {
        guard let string = string else {
            return nil
        }
        
        return Float(string)
    }
    
    public var double: Double? {
        guard let string = string else {
            return nil
        }
        
        return Double(string)
    }

    public var boolean: Bool? {
        guard let string = string else {
            return nil
        }
        
        switch string {
        case "TRUE", "True", "true", "yes", "1", "t", "y":
            return true
        case "FALSE", "False", "false", "no", "0", "f", "n":
            return false
        default:
            return nil
        }
    }
    
    public var integer: Int? {
        guard let string = string else {
            return nil
        }
        
        return Int(string)
    }
    
    public var string: String? {
        return data.string
    }
    
    public var description: String {
        return string ?? "Not representable"
    }
}