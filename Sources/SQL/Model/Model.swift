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

public protocol ModelFieldset: CustomStringConvertible {
    static var tableName: String { get }

    var qualifiedName: String { get }

    var unqualifiedName: String { get }

    var alias: String { get }
}

public extension ModelFieldset where Self: RawRepresentable, Self.RawValue == String {
    public var unqualifiedName: String {
        return rawValue
    }
}

public extension ModelFieldset {

    public var qualifiedName: String {
        return "\(self.dynamicType.tableName).\(unqualifiedName)"
    }

    public var alias: String {
        return "\(self.dynamicType.tableName)__\(unqualifiedName)"
    }

    public var description: String {
        return qualifiedName
    }

    public func containedIn(values: [ValueConvertible?]) -> Condition {
        return .In(qualifiedName, values)
    }

    public func containedIn(values: ValueConvertible?...) -> Condition {
        return .In(qualifiedName, values)
    }

    public func notContainedIn(values: [ValueConvertible?]) -> Condition {
        return .NotIn(qualifiedName, values)
    }

    public func notContainedIn(values: ValueConvertible?...) -> Condition {
        return .NotIn(qualifiedName, values)
    }
}

public func == <T: ModelFieldset>(lhs: T, rhs: ValueConvertible?) -> Condition {
    return .Equals(lhs.qualifiedName, .Value(rhs))
}

public func == <L: ModelFieldset, R: ModelFieldset>(lhs: L, rhs: R) -> Condition {
    return .Equals(lhs.qualifiedName, .Property(rhs.qualifiedName))
}

public func > <T: ModelFieldset>(lhs: T, rhs: ValueConvertible?) -> Condition {
    return .GreaterThan(lhs.qualifiedName, .Value(rhs))
}

public func > <L: ModelFieldset, R: ModelFieldset>(lhs: L, rhs: R) -> Condition {
    return .GreaterThan(lhs.qualifiedName, .Property(rhs.qualifiedName))
}


public func >= <T: ModelFieldset>(lhs: T, rhs: ValueConvertible?) -> Condition {
    return .GreaterThanOrEquals(lhs.qualifiedName, .Value(rhs))
}

public func >= <L: ModelFieldset, R: ModelFieldset>(lhs: L, rhs: R) -> Condition {
    return .GreaterThanOrEquals(lhs.qualifiedName, .Property(rhs.qualifiedName))
}


public func < <T: ModelFieldset>(lhs: T, rhs: ValueConvertible?) -> Condition {
    return .LessThan(lhs.qualifiedName, .Value(rhs))
}

public func < <L: ModelFieldset, R: ModelFieldset>(lhs: L, rhs: R) -> Condition {
    return .LessThan(lhs.qualifiedName, .Property(rhs.qualifiedName))
}


public func <= <T: ModelFieldset>(lhs: T, rhs: ValueConvertible?) -> Condition {
    return .LessThanOrEquals(lhs.qualifiedName, .Value(rhs))
}

public func <= <L: ModelFieldset, R: ModelFieldset>(lhs: L, rhs: R) -> Condition {
    return .LessThanOrEquals(lhs.qualifiedName, .Property(rhs.qualifiedName))
}

public func == <L: ModelFieldset, R: ModelFieldset>(lhs: L, rhs: R) -> JoinKey<L, R> {
    return JoinKey(left: lhs, right: rhs)
}

public protocol Model {
    associatedtype Field: ModelFieldset, Hashable

    init(row: Row) throws
}

public extension Model {
    public static func select(fields: ModelFieldset...) -> Select<Self> {
        return Select(fields: fields)
    }

    public static func insert(valuesByFieldName: [Field: ValueConvertible?]) -> Insert<Self> {
        return Insert(valuesByFieldName)
    }
}
