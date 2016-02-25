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

public protocol FetchableModelQuery: ModelQuery {
    var offset: Int? { get set }
    var limit: Int? { get set }
}

public extension FetchableModelQuery {
    
    public var pageSize: Int? {
        get {
            return limit
        }
        set {
            limit = newValue
        }
    }
    
    public func page(value: Int?) -> Self {
        var new = self
        new.page = value
        return new
    }
    
    public var page: Int? {
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



public protocol FilteredQuery {
    var condition: Condition? { get set }
}

extension FilteredQuery {
    public func filter(condition: Condition) -> Self {
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
}


public enum JoinType<T: Model>: StatementConvertible {
    case Inner(T.Type)
    case Outer(T.Type)
    case Left(T.Type)
    case Right(T.Type)

    public var statement: Statement {
        switch self {
        case .Left:
            return "LEFT JOIN \(T.tableName)"
        case .Right:
            return "RIGHT JOIN \(T.tableName)"
        case .Inner:
            return "INNER JOIN \(T.tableName)"
        case .Outer:
            return "OUTER JOIN \(T.tableName)"
        }
    }
}

internal struct Join: StatementConvertible {
    
    let typeStatement: Statement
    let leftKey: String
    let rightKey: String

    var statement: Statement {
        return Statement(substatements: [
            typeStatement,
            Statement(components: ["ON", leftKey, "=" ,rightKey])
            ]
        )
    }

    init<R: Model>(type: JoinType<R>, key: DeclaredField, on: R.Field) {
        self.typeStatement = type.statement
        self.leftKey = key.qualifiedName
        self.rightKey = R.field(on).qualifiedName
    }
}