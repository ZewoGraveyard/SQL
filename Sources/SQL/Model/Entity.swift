// Entity.swift
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

public protocol Entity: Model {
    associatedtype PrimaryKeyType: ValueConvertible

    var primaryKey: PrimaryKeyType? { get }
    static var fieldForPrimaryKey: Field { get }
    
    func serialize() throws -> [Field: ValueConvertible?]
}

public extension Entity {
    var isPersisted: Bool {
        return primaryKey != nil
    }
    
    public static func delete() -> Delete<Self> {
        return Delete()
    }
    
    public func updateQuery(values: [Field: ValueConvertible?]) -> Update<Self> {
        return Update(values).filter(Self.fieldForPrimaryKey == primaryKey)
    }
    
    public mutating func update<T: Connection where T.ResultType.Generator.Element == Row>(values: [Field: ValueConvertible?], connection: T) throws -> Self {
        try updateQuery(values).run(connection)
        try refresh(connection)
        return self
    }
    
    public static func find<T: Connection where T.ResultType.Generator.Element == Row>(pk: Self.PrimaryKeyType, connection: T) throws -> Self? {
        return try select().filter(fieldForPrimaryKey == pk).first(connection)
    }
    
    public mutating func refresh<T: Connection where T.ResultType.Generator.Element == Row>(connection: T) throws {
        guard let pk = primaryKey else {
            fatalError()
        }
        
        guard let newSelf = try Self.find(pk, connection: connection) else {
            fatalError()
        }
        
        self = newSelf
    }

}