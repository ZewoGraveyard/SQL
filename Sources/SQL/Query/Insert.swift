// Insert.swift
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

public struct Insert<M: Model>: ModelQuery {
    public typealias ModelType = M
    
    internal var valuesByField: [DeclaredField: SQL.Value?] = [:]
    
    public func set(field: DeclaredField, value: ValueConvertible?) -> Insert {
        var new = self
        new.valuesByField[field] = value?.SQLValue
        return new
    }
    
    public init(_ valuesByFieldName: [DeclaredField: ValueConvertible?]) {
        self.valuesByField = valuesByFieldName
    }
}

extension Insert: StatementConvertible {
    public var statement: Statement {
        var statement = Statement(components: ["INSERT INTO", M.tableName], parameters: Array(valuesByField.values))
        
        statement.appendComponent(
            "(\(valuesByField.keys.map { $0.unqualifiedName }.joinWithSeparator(", ")))"
        )
        
        statement.appendComponent("VALUES")
        
        var strings = [String]()
        for _ in valuesByField {
            strings.append("%@")
        }
        
        
        statement.appendComponent("(\(strings.joinWithSeparator(",")))")
        
        return statement
    }
}