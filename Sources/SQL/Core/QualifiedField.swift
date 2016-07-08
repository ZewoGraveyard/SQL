// QualifiedField.swift
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


public struct QualifiedField {
    public let unqualifiedName: String
    public var tableName: String?
    public var alias: String?
    
    public init(_ name: String, alias: String? = nil) {
        let components = name.split(separator: ".")
        if components.count == 2, let tableName = components.first, let fieldName = components.last {
            self.unqualifiedName = fieldName
            self.tableName = tableName
        }
        else {
            self.unqualifiedName = name
            self.tableName = nil
        }
        
        self.alias = alias
    }
    
    func alias(_ alias: String) -> QualifiedField {
        var new = self
        new.alias = alias
        return new
    }
}

extension QualifiedField: ParameterConvertible {
    public var sqlParameter: Parameter {
        return .field(self)
    }
}

public extension QualifiedField {
    public var qualifiedName: String {
        guard let tableName = tableName else {
            return unqualifiedName
        }
        return tableName + "." + unqualifiedName
    }
}

extension QualifiedField: Hashable {
    public var hashValue: Int {
        return qualifiedName.hashValue
    }
}

public func == (lhs: QualifiedField, rhs: QualifiedField) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
