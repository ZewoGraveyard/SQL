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

public struct Insert {
    public let valuesByField: [QualifiedField: Value?]
    
    public let tableName: String
    
    public init(_ tableName: String, values: [QualifiedField: Value?]) {
        self.tableName = tableName
        self.valuesByField = values
    }
    
    public init(_ tableName: String, values: [QualifiedField: ValueConvertible?]) {
        var transformed = [QualifiedField: Value?]()
        
        for (key, value) in values {
            transformed[key] = value?.sqlValue
        }
        
        self.init(tableName, values: transformed)
    }
}

extension Insert: StatementParameterListConvertible {
    public var sqlParameters: [Value?] {
        return Array(valuesByField.values)
    }
}
