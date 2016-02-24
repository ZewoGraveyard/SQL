// Select.swift
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

public struct Select<M: Model>: FetchableModelQuery, FilteredQuery {
    public typealias ModelType = M
    public let fields: [ModelFieldset]
    
    public var offset: Int?
    public var limit: Int?
    
    var joins: [Join] = []
    
    public func join<T: Model>(type: JoinType<T>, on key: JoinKey<M.Field, T.Field>) -> Select {
        var new = self
        new.joins.append(Join(type: type, key: key))
        return new
    }
    
    public var condition: Condition?
    
    
    public init(fields: [ModelFieldset]) {
        self.fields = fields
    }
    
    public init(_ fields: ModelFieldset...) {
        self.init(fields: fields)
    }
    
    public init() {
        self.init(fields: [])
    }
    
    public func offset(value: Int?) -> Select {
        var new = self
        new.offset = value
        return new
    }
    
    public func limit(value: Int?) -> Select {
        var new = self
        new.limit = value
        return new
    }
}

extension Select: StatementConvertible {
    public var statement: Statement {
        
        let fieldString = fields.isEmpty ? "*" : fields.map { "\($0.qualifiedName) AS \($0.alias)" }.joinWithSeparator(", ")
        
        var statement = Statement(components: ["SELECT", fieldString, "FROM", ModelType.Field.tableName])
        
        
        for join in joins {
            statement.append(join.statement)
        }
        
        if let condition = condition {
            statement.appendComponent("WHERE")
            
            statement.append(condition.statement)
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