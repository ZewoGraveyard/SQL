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
    public var float: Float {
        return UnsafePointer<Float>(data).memory
    }
    
    public var double: Double {
        return UnsafePointer<Double>(data).memory
    }
    
    public var integer: Int {
        return UnsafePointer<Int>(data).memory
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