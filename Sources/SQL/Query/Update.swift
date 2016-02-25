// Update.swift
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

public struct Update<M: Model>: ModelQuery, FilteredQuery {
    public typealias ModelType = M
    
    public var condition: Condition?
    
    internal var valuesByField: [DeclaredField: ValueConvertible?] = [:]
    
    public func set(field: DeclaredField, value: ValueConvertible?) -> Update {
        var new = self
        new.valuesByField[field] = value
        return new
    }
    
    public init(_ valuesByFieldName: [DeclaredField: ValueConvertible?]) {
        self.valuesByField = valuesByFieldName
    }
    
    public init(_ valuesByFieldName: [M.Field: ValueConvertible?]) {
        self.init(valuesByFieldName.SQLValueDictionary)
    }
    
}

extension Update: StatementConvertible {
    public var statement: Statement {
        
        var statement = Statement(components: ["UPDATE", ModelType.tableName, "SET"], parameters: Array(valuesByField.values))
        
        var strings = [String]()
        for (field, _) in valuesByField {
            strings.append("\(field.unqualifiedName) = %@")
        }
        
        statement.appendComponent("\(strings.joinWithSeparator(","))")
        
        if let condition = condition {
            statement.appendComponent("WHERE")
            statement.append(condition.statement)
        }
        
        return statement
    }
}