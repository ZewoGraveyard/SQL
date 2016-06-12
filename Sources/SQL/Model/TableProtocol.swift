// TableProtocol.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2016 Formbound
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


public protocol TableField: RawRepresentable, Hashable, ParameterConvertible {
    static var tableName: String { get }
}

public extension TableField {
    public var sqlParameter: Parameter {
        return .field(qualifiedField)
    }
    
    public var qualifiedField: QualifiedField {
        return QualifiedField("\(Self.tableName).\(self.rawValue)", alias: "\(Self.tableName)__\(self.rawValue)")
    }
}

public protocol TableProtocol {
    associatedtype Field: TableField
    
}

public extension TableProtocol where Self.Field.RawValue == String {
    
    public static func select(_ fields: Field...) -> Select {
        return Select(fields.map { $0.qualifiedField }, from: [Field.tableName])
    }
    
    public static func select(where predicate: Predicate) -> Select {
        return select.filtered(predicate)
    }
    
    public static var select: Select {
        return Select("*", from: Field.tableName)
    }
 
    public static func update(_ dict: [Field: ValueConvertible?]) -> Update {
        var translated = [QualifiedField: ValueConvertible?]()
        
        for (key, value) in dict {
            translated[key.qualifiedField] = value
        }
        
        var update = Update(Field.tableName)
        update.set(translated)
        
        return update
    }
    
    public static func insert(_ dict: [Field: ValueConvertible?]) -> Insert {
        var translated = [QualifiedField: ValueConvertible?]()
        
        for (key, value) in dict {
            translated[key.qualifiedField] = value
        }
        
        return Insert(Field.tableName, values: translated)
    }
    
    public static func delete(where predicate: Predicate) -> Delete {
        return Delete(from: Field.tableName).filtered(predicate)
    }
    
    public static var delete: Delete {
        return Delete(from: Field.tableName)
    }
}
