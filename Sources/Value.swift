//  Value.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Formbound
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


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