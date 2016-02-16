// Query.swift
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


public protocol Query: StatementConvertible {

}

public extension Query {
    public func execute<T: Connection>(connection: T) throws -> T.ResultType {
        return try connection.execute(self)
    }
}

public protocol ModelQuery: Query {
    associatedtype ModelType: Model
}

internal protocol FilteredQuery {
    var condition: Condition? { get }
}

public struct JoinKey<L: ModelFieldset, R: ModelFieldset> {
    let left: L
    let right: R
}

public enum JoinType<T: Model>: CustomStringConvertible {
    case Inner(T.Type)
    case Outer(T.Type)
    case Left(T.Type)
    case Right(T.Type)

    public var description: String {
        switch self {
        case .Left:
            return "LEFT JOIN \(T.Field.tableName)"
        case .Right:
            return "RIGHT JOIN \(T.Field.tableName)"
        case .Inner:
            return "INNER JOIN \(T.Field.tableName)"
        case .Outer:
            return "OUTER JOIN \(T.Field.tableName)"
        }
    }
}

internal struct Join: StatementConvertible {
    internal let type: String
    internal let leftKey: String
    internal let rightKey: String

    internal func statementWithParameterOffset(inout parameterOffset: Int) -> Statement {
        return Statement(components: [type, "ON", leftKey, "=" ,rightKey])
    }

    internal init<L: ModelFieldset, R: Model>(type: JoinType<R>, key: JoinKey<L, R.Field>) {
        self.type = type.description
        self.leftKey = key.left.qualifiedName
        self.rightKey = key.right.qualifiedName
    }
}

public struct Delete<M: Model>: ModelQuery, FilteredQuery {
    public typealias ModelType = M

    internal var condition: Condition?
}

extension Delete: StatementConvertible {
    public func statementWithParameterOffset(inout parameterOffset: Int) -> Statement {

        var statement = Statement(components: ["DELETE", "FROM", ModelType.Field.tableName])

        if let condition = condition {
            statement.appendComponent("WHERE")
            statement.merge(condition.statementWithParameterOffset(&parameterOffset))
        }

        return statement
    }
}

public struct Insert<M: Model>: ModelQuery {
    public typealias ModelType = M

    internal var valuesByFieldName: [M.Field: ValueConvertible?] = [:]

    public func set(field: M.Field, value: ValueConvertible?) -> Insert {
        var new = self
        new.valuesByFieldName[field] = value
        return new
    }

    public init(_ valuesByFieldName: [M.Field: ValueConvertible?]) {
        self.valuesByFieldName = valuesByFieldName
    }
}

extension Insert: StatementConvertible {
    public func statementWithParameterOffset(inout parameterOffset: Int) -> Statement {
        var statement = Statement(components: ["INSERT INTO", M.Field.tableName], parameters: Array(valuesByFieldName.values))

        statement.appendComponent(
            "(\(valuesByFieldName.keys.map { $0.unqualifiedName }.joinWithSeparator(", ")))"
        )

        statement.appendComponent("VALUES")

        let parameterString = (parameterOffset..<parameterOffset + valuesByFieldName.count).map {
            return "$\($0)"
            }.joinWithSeparator(",")


        statement.appendComponent("(\(parameterString))")

        return statement
    }
}


public struct Select<M: Model>: ModelQuery, FilteredQuery {
    public typealias ModelType = M
    public let fields: [ModelFieldset]

    public var offset: UInt?
    public var limit: UInt?

    public var pageSize: UInt? {
        get {
            return limit
        }
        set {
            limit = newValue
        }
    }

    var joins: [Join] = []

    public func join<T: Model>(type: JoinType<T>, on key: JoinKey<M.Field, T.Field>) -> Select {
        var new = self
        new.joins.append(Join(type: type, key: key))
        return new
    }

    public var page: UInt? {
        set {
            guard let value = newValue, limit = limit else {
                offset = nil
                return
            }
            offset = value * limit
        }

        get {
            guard let offset = offset, limit = limit else {
                return nil
            }

            return offset / limit
        }
    }

    internal var condition: Condition?


    public init(fields: [ModelFieldset]) {
        self.fields = fields
    }

    public init(_ fields: ModelFieldset...) {
        self.init(fields: fields)
    }

    public init() {
        self.init(fields: [])
    }

    public func offset(value: UInt?) -> Select {
        var new = self
        new.offset = value
        return new
    }

    public func limit(value: UInt?) -> Select {
        var new = self
        new.limit = value
        return new
    }

    public func page(value: UInt?) -> Select {
        var new = self
        new.page = value
        return new
    }

    public func filter(condition: Condition) -> Select {
        let newCondition: Condition
        if let existing = self.condition {
            newCondition = .And([existing, condition])
        }
        else {
            newCondition = condition
        }

        var new = self
        new.condition = newCondition

        return new
    }

    public func fetch<T: Connection where T.ResultType.Generator.Element == Row>(connection: T) throws -> [ModelType] {
        return try connection.execute(self).map { try ModelType(row: $0) }
    }

    public func first<T: Connection where T.ResultType.Generator.Element == Row>(connection: T) throws -> ModelType? {
        var new = self
        new.offset = 0
        new.limit = 1
        return try connection.execute(new).map { try ModelType(row: $0) }.first
    }
}

extension Select: StatementConvertible {
    public func statementWithParameterOffset(inout parameterOffset: Int) -> Statement {

        let fieldString = fields.isEmpty ? "*" : fields.map { "\($0.qualifiedName) AS \($0.alias)" }.joinWithSeparator(", ")

        var statement = Statement(components: ["SELECT", fieldString, "FROM", ModelType.Field.tableName])


        for join in joins {
            statement.merge(join.statementWithParameterOffset(&parameterOffset))
        }

        if let condition = condition {
            statement.appendComponent("WHERE")

            statement.merge(condition.statementWithParameterOffset(&parameterOffset))
        }

        if let limit = limit {
            statement.appendComponent("LIMIT \(limit)")
        }

        if let offset = offset {
            statement.appendComponent("OFFSET \(offset)")
        }

        return statement
    }
}
