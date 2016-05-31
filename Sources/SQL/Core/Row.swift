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


public protocol RowConvertible {
    init(row: Row) throws
}

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
    case expectedQualifiedField(QualifiedField)
    case unexpectedNilValue(QualifiedField)
}

public extension RowProtocol {
    
    public var fields: [String] {
        return Array(dataByfield.keys)
    }
    
    // MARK: - Data
    
    public func data(_ field: QualifiedField) throws -> Data? {
    
        var data: Data??
        
        if let alias = field.alias {
            data = dataByfield[alias]
        }
        else {
            data = dataByfield[field.unqualifiedName]
        }
        
        guard let result = data else {
            throw RowProtocolError.expectedQualifiedField(field)
        }
        return result
    }
    
    public func data(_ field: QualifiedField) throws -> Data {
        guard let data: Data = try data(field) else {
            throw RowProtocolError.unexpectedNilValue(field)
        }
        
        return data
    }
    
    public func data(_ field: String) throws -> Data {
        let field = QualifiedField(field)
        guard let data: Data = try data(field) else {
            throw RowProtocolError.unexpectedNilValue(field)
        }
        
        return data
    }
    
    // MARK: - ValueConvertible
    
    public func value<T: ValueConvertible>(_ field: QualifiedField) throws -> T? {
        guard let data: Data = try data(field) else {
            return nil
        }
        
        return try T(rawSQLData: data)
    }
    
    public func value<T: ValueConvertible>(_ field: QualifiedField) throws -> T {
        guard let data: Data = try data(field) else {
            throw RowProtocolError.unexpectedNilValue(field)
        }
        
        return try T(rawSQLData: data)
    }
    
    // MARK - String support
    
    public func data(field: String) throws -> Data? {
        return try data(QualifiedField(field))
    }
    
    public func value<T: ValueConvertible>(_ field: String) throws -> T? {
        return try value(QualifiedField(field))
    }
    
    public func value<T: ValueConvertible>(_ field: String) throws -> T {
        return try value(QualifiedField(field))
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