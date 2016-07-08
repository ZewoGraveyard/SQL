// Join.swift
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

public struct Join {
    public enum `Type` {
        case inner(String)
        case outer(String)
    }
    
    public let leftKey: QualifiedField
    public let rightKey: QualifiedField
    public let type: Type
    
    public init(type: `Type`, leftKey: QualifiedField, rightKey: QualifiedField) {
        self.type = type
        self.leftKey = leftKey
        self.rightKey = rightKey
    }
}

extension Join: StatementStringRepresentable {
    public var sqlString: String {
        return "\(type.sqlString) ON \(leftKey.qualifiedName) = \(rightKey.qualifiedName)"
    }
}

extension Join.`Type`: StatementStringRepresentable {
    public var sqlString: String {
        switch self {
        case .inner(let table):
            return "INNER JOIN \(table)"
        case .outer(let table):
            return "OUTER JOIN \(table)"
        }
    }
}
