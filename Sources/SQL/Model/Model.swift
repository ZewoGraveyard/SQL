// Model.swift
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

public struct DeclaredField: CustomStringConvertible {
    let unqualifiedName: String
    let tableName: String
}

extension DeclaredField: Hashable {
    public var hashValue: Int {
        return qualifiedName.hashValue
    }
}

public func == (lhs: DeclaredField, rhs: DeclaredField) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public extension DeclaredField {

    public var qualifiedName: String {
        return "\(tableName).\(unqualifiedName)"
    }

    public var alias: String {
        return "\(tableName)__\(unqualifiedName)"
    }

    public var description: String {
        return qualifiedName
    }

    public func containedIn(values: [ValueConvertible?]) -> Condition {
        return .In(qualifiedName, values.map { $0?.SQLValue })
    }

    public func containedIn(values: ValueConvertible?...) -> Condition {
        return .In(qualifiedName, values.map { $0?.SQLValue })
    }

    public func notContainedIn(values: [ValueConvertible?]) -> Condition {
        return .NotIn(qualifiedName, values.map { $0?.SQLValue })
    }

    public func notContainedIn(values: ValueConvertible?...) -> Condition {
        return .NotIn(qualifiedName, values.map { $0?.SQLValue })
    }
    
    public func equals(value: ValueConvertible?) -> Condition {
        return .Equals(qualifiedName, .Value(value?.SQLValue))
    }
}

public func == (lhs: DeclaredField, rhs: ValueConvertible?) -> Condition {
    return lhs.equals(rhs)
}

public func == (lhs: DeclaredField, rhs: DeclaredField) -> Condition {
    return .Equals(lhs.qualifiedName, .Property(rhs.qualifiedName))
}

public func > (lhs: DeclaredField, rhs: ValueConvertible?) -> Condition {
    return .GreaterThan(lhs.qualifiedName, .Value(rhs?.SQLValue))
}

public func > (lhs: DeclaredField, rhs: DeclaredField) -> Condition {
    return .GreaterThan(lhs.qualifiedName, .Property(rhs.qualifiedName))
}


public func >= (lhs: DeclaredField, rhs: ValueConvertible?) -> Condition {
    return .GreaterThanOrEquals(lhs.qualifiedName, .Value(rhs?.SQLValue))
}

public func >= (lhs: DeclaredField, rhs: DeclaredField) -> Condition {
    return .GreaterThanOrEquals(lhs.qualifiedName, .Property(rhs.qualifiedName))
}


public func < (lhs: DeclaredField, rhs: ValueConvertible?) -> Condition {
    return .LessThan(lhs.qualifiedName, .Value(rhs?.SQLValue))
}

public func < (lhs: DeclaredField, rhs: DeclaredField) -> Condition {
    return .LessThan(lhs.qualifiedName, .Property(rhs.qualifiedName))
}


public func <= (lhs: DeclaredField, rhs: ValueConvertible?) -> Condition {
    return .LessThanOrEquals(lhs.qualifiedName, .Value(rhs?.SQLValue))
}

public func <= (lhs: DeclaredField, rhs: DeclaredField) -> Condition {
    return .LessThanOrEquals(lhs.qualifiedName, .Property(rhs.qualifiedName))
}


public protocol FieldType: RawRepresentable, Hashable {
    var rawValue: String { get }
    
    init?(rawValue: String)
}

public struct ModelError: ErrorType {
    let description: String
}

public protocol Model {
    associatedtype Field: FieldType
    associatedtype PrimaryKeyType: ValueConvertible
    
    var primaryKey: PrimaryKeyType? { get }
    static var fieldForPrimaryKey: Field { get }
    
    static var tableName: String { get }
    
    static var selectFieldset: [Field] { get }
   
    var persistedValuesByField: [Field: ValueConvertible?] { get }
    
    init(row: Row) throws
}

public extension Model {
    public static func fetch<T: Connection where T.ResultType.Generator.Element == Row>(connection: T, build: Select<Self> -> Void) throws -> [Self] {
        let selectQuery: Select<Self> = Select(selectFieldset)
        build(selectQuery)
        return try selectQuery.fetch(connection)
    }
    
    public static var selectFieldset: [Field] {
        return []
    }

    public static func field(field: Field) -> DeclaredField {
        return DeclaredField(unqualifiedName: field.rawValue, tableName: Self.tableName)
    }
    
    public static func field(field: String) -> DeclaredField {
        return DeclaredField(unqualifiedName: field, tableName: Self.tableName)
    }
    
    public var isPersisted: Bool {
        return primaryKey != nil
    }
    
    public static var primaryKeyField: DeclaredField {
        return field(fieldForPrimaryKey)
    }
    
    public static func find<T: Connection where T.ResultType.Generator.Element == Row>(pk: PrimaryKeyType, connection: T) throws -> Self? {
        let selectQuery: Select<Self> = Select(selectFieldset).filter(primaryKeyField == pk)
        return try selectQuery.first(connection)
    }
    
    public static func find<T: Connection where T.ResultType.Generator.Element == Row>(pks: [PrimaryKeyType], connection: T) throws -> [Self] {
        let selectQuery: Select<Self> = Select(selectFieldset).filter(primaryKeyField.containedIn(pks.map { $0 as ValueConvertible }))
        return try selectQuery.fetch(connection)
    }
    
    public mutating func update<T: Connection where T.ResultType.Generator.Element == Row>(connection: T) throws -> Self {
        guard let pk = primaryKey else {
            throw ModelError(description: "Cannot update. Model is not persisted")
        }
        
        let updateQuery: Update<Self> = Update(persistedValuesByField).filter(Self.primaryKeyField == pk)
        try updateQuery.execute(connection)
        
        try self.refresh(connection)
        
        return self
    }

    public mutating func refresh<T: Connection where T.ResultType.Generator.Element == Row>(connection: T) throws {
        guard let pk = primaryKey else {
            throw ModelError(description: "Cannot refresh. Model is not persisted")
        }
        
        guard let newSelf = try Self.find(pk, connection: connection) else {
            throw ModelError(description: "Cannot refresh. Model with primary key \(pk) was not found")
        }
        
        self = newSelf
    }
}

