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

public class Select<M: Model>: FetchableModelQuery, FilteredQuery {
    public typealias ModelType = M
    public let fields: [DeclaredField]
    
    public var offset: Int?
    public var limit: Int?
    
    var joins: [Join] = []
    
    
    
    public func join<M: Model>(type: JoinType<M>, key: ModelType.Field, on: M.Field) -> Select {
        joins.append(Join(type: type, key: ModelType.field(key), on: on))
        return self
    }
    
    public var condition: Condition?
    
    public convenience init(_ fields: [M.Field]) {
        self.init(fields.map { M.field($0) })
    }
    
    public convenience init(_ fields: M.Field...) {
        self.init(fields)
    }
    
    public init(_ fields: [DeclaredField]) {
        self.fields = fields
    }
    
    public convenience init(_ fields: DeclaredField...) {
        self.init(fields)
    }
    
    public convenience init() {
        self.init([DeclaredField]())
    }
    
    public func offset(value: Int?) -> Select {
        offset = value
        return self
    }
    
    public func limit(value: Int?) -> Select {
        limit = value
        return self
    }
}

extension Select: StatementConvertible {
    public var statement: Statement {
        
        let fieldString = fields.isEmpty ? "*" : fields.map { "\($0.qualifiedName) AS \($0.alias)" }.joinWithSeparator(", ")
        
        var statement = Statement(components: ["SELECT", fieldString, "FROM", ModelType.tableName])
        
        
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