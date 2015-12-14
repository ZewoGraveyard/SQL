//
//  Value.swift
//  SQL
//
//  Created by David Ask on 10/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//


public protocol Value: CustomStringConvertible {
    
    var data: [UInt8] { get }
    
    init(data: [UInt8])
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
        
        return Bool(string)
    }
    
    public var integer: Int? {
        guard let string = string else {
            return nil
        }
        
        return Int(string)
    }
    
    public var string: String? {
        
        var encoding = UTF8()
        
        var str = ""
        
        var generator = data.generate()
        
        repeat {
            switch encoding.decode(&generator) {
            case .Result(let scalar):
                str.append(scalar)
                break
                
            case .EmptyInput:
                return str
                
            case .Error:
                return nil
            }
        } while true
        
    }
    
    public var description: String {
        return string ?? "Not representable"
    }
}