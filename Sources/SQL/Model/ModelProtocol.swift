// ModelProtocol.swift
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


public protocol ModelField: TableField {
    static var primaryKey: Self { get }
}

public protocol ModelProtocol: TableProtocol, TableRowConvertible {
    associatedtype PrimaryKey: Hashable, ValueConvertible
    associatedtype Field: ModelField
    
    func serialize() -> [Field: ValueConvertible?]
    
    func willSave() throws
    func didSave()
    
    func willUpdate() throws
    func didUpdate()
    
    func willCreate() throws
    func didCreate()
    
    func willDelete() throws
    func didDelete()
    
    func willRefresh() throws
    func didRefresh()
}

public extension ModelProtocol {
    public func willSave() throws {}
    public func didSave() {}
    
    public func willUpdate() throws {}
    public func didUpdate() {}
    
    public func willCreate() throws {}
    public func didCreate() {}
    
    public func willDelete() throws {}
    public func didDelete() {}
    
    public func willRefresh() throws {}
    public func didRefresh() {}
}

public struct EntityError: ErrorProtocol, CustomStringConvertible {
    public let description: String
    
    public init(_ description: String) {
        self.description = description
    }
}
