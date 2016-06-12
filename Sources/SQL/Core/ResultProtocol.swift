// ResultProtocol.swift
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

public protocol ResultStatus {
    var successful: Bool { get }
}

public protocol ResultProtocol: Collection {
    associatedtype FieldInfo: FieldInfoProtocol

    func clear()

    var fieldsByName: [String: FieldInfo] { get }

    subscript(index: Int) -> Iterator.Element { get }

    var count: Int { get }
    
    func data(atRow rowIndex: Int, forFieldIndex fieldIndex: Int) -> Data?
}

extension ResultProtocol {
    
    public var fields: [FieldInfo] {
        return Array(fieldsByName.values)
    }
    
    public func index(ofFieldByName name: String) -> Int? {
        guard let field = fieldsByName[name] else {
            return nil
        }
        
        return field.index
    }

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return count
    }
    
    public func index(after: Int) -> Int {
        return after + 1
    }
}
