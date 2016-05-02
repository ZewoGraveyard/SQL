// Row.swift
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

@_exported import String

public struct Row: RowProtocol {
    
    public var dataByfield: [String: Data?]
    
    public init(dataByfield: [String: Data?]) {
        self.dataByfield = dataByfield
    }
}

public protocol RowProtocol: CustomStringConvertible {
    init(dataByfield: [String: Data?])
    
    var fields: [String] { get }
    
    var dataByfield: [String: Data?] { get }
}

public enum RowProtocolError: ErrorProtocol {
    case ExpectedField(DeclaredField)
    case UnexpectedNilValue(DeclaredField)
}

public extension RowProtocol {
    
    public var fields: [String] {
        return Array(dataByfield.keys)
    }
    
    // MARK: - Data
    
    public func data(_ field: DeclaredField) throws -> Data? {
        
        /*
         Supplying a fielName can done either
         1. Qualified, e.g. 'users.id'
         2. Non-qualified e.g. 'id'
         
         A statement will cast qualified fields from 'users.id' to 'users__id'
         
         Because of this, a given field name must be checked for three type of keys
         
         */
        let fieldCandidates = [
            field.unqualifiedName,
            field.alias,
            field.qualifiedName
        ]
        
        var data: Data??
        
        for fieldNameCandidate in fieldCandidates {
            data = dataByfield[fieldNameCandidate]
            
            if data != nil {
                break
            }
        }
        
        guard let result = data else {
            throw RowProtocolError.ExpectedField(field)
        }
        return result
    }
    
    public func data(_ field: DeclaredField) throws -> Data {
        guard let data: Data = try data(field) else {
            throw RowProtocolError.UnexpectedNilValue(field)
        }
        
        return data
    }
    
    public func data(_ field: String) throws -> Data {
        let field = DeclaredField(name: field)
        guard let data: Data = try data(field) else {
            throw RowProtocolError.UnexpectedNilValue(field)
        }
        
        return data
    }
    
    // MARK: - SQLDataConvertible
    
    public func value<T: SQLDataConvertible>(_ field: DeclaredField) throws -> T? {
        guard let data: Data = try data(field) else {
            return nil
        }
        
        return try T(rawSQLData: data)
    }
    
    public func value<T: SQLDataConvertible>(_ field: DeclaredField) throws -> T {
        guard let data: Data = try data(field) else {
            throw RowProtocolError.UnexpectedNilValue(field)
        }
        
        return try T(rawSQLData: data)
    }
    
    // MARK - String support
    
    public func data(field: String) throws -> Data? {
        return try data(DeclaredField(name: field))
    }
    
    public func value<T: SQLDataConvertible>(_ field: String) throws -> T? {
        return try value(DeclaredField(name: field))
    }
    
    public func value<T: SQLDataConvertible>(_ field: String) throws -> T {
        return try value(DeclaredField(name: field))
    }
    
    
    public var description: String {        
        return dataByfield.map {
            (key, value) in
            
            guard let value = value else {
                return "NULL"
            }
            
            return "\(key): \(value)"
        }.joined(separator: ", ")

    }
}