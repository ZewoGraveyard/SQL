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


public struct Select: SelectQuery {
    public private(set) var fields: [QueryComponentsRepresentable]
    
    public let tableName: String
    
    public var condition: Condition? = nil

    public var joins: [Join] = []
    
    public var offset: Offset? = nil
    
    public var limit: Limit? = nil
    
    public var orderBy: [OrderBy] = []

    public var groupBy: [GroupBy] = []


    public init(fields: [QueryComponentsRepresentable], from tableName: String) {
        self.tableName = tableName
        self.fields = fields
    }

    public init(_ fields: QueryComponentsRepresentable..., from tableName: String) {
        self.init(fields: fields, from: tableName)
    }


    public init<T: Table>(_ fields: T.Field..., from table: T.Type ) {
        self.init(fields: fields.map {table.field($0)}, from: table.tableName)
    }


    public init(from tableName: String) {
        self.init(fields: [], from: tableName)
    }


    public func select(fields fields: [QueryComponentsRepresentable]) -> Select {
        var new = self
        new.fields.append(contentsOf: fields)
        return new
    }

    public func select(fields: QueryComponentsRepresentable...) -> Select {
        return self.select(fields: fields)
    }


    public func join(tableClause: QueryComponents, using type: [Join.JoinType], leftKey: QueryComponentsRepresentable, rightKey: QueryComponentsRepresentable) -> Select {
        var new = self
        new.joins.append(
            Join(tableClause, type: type, leftKey: leftKey, rightKey: rightKey)
        )
        
        return new
    }
    
    public func join(tableName: String, using type: Join.JoinType, leftKey: QueryComponentsRepresentable, rightKey: QueryComponentsRepresentable) -> Select {
        return join(QueryComponents(tableName), using: [type], leftKey: leftKey, rightKey: rightKey)
    }

    public func join(queryComponents: QueryComponentsRepresentable, type: Join.JoinType, leftKey: QueryComponentsRepresentable, rightKey: QueryComponentsRepresentable) -> Select {
        return join(queryComponents.queryComponents, using: [type], leftKey: leftKey, rightKey: rightKey)
    }
}

extension Select {
    public func asSubquery(alias: String) -> Subquery {
        return Subquery(components: queryComponents, alias: alias)
    }
}

public struct ModelSelect<T: Model>: SelectQuery, ModelQuery {
    public typealias ModelType = T
    
    public var tableName: String {
        return T.tableName
    }
    
    public let fields: [QueryComponentsRepresentable]
    
    public var condition: Condition? = nil
    
    public var joins: [Join] = []
    
    public var offset: Offset? = nil
    
    public var limit: Limit? = nil
    
    public var orderBy: [OrderBy] = []

    public var groupBy: [GroupBy] = []

    public func join<R: Model>(model: R.Type, using type: [Join.JoinType], leftKey: ModelType.Field, rightKey: R.Field) -> ModelSelect<T> {
        var new = self
        new.joins.append(
            Join(QueryComponents(R.tableName), type: type, leftKey: ModelType.field(leftKey).qualifiedName, rightKey: R.field(rightKey).qualifiedName)
        )

        return new
    }
    
    public func join<R: Model>(model: R.Type, using type: Join.JoinType, leftKey: ModelType.Field, rightKey: R.Field) -> ModelSelect<T> {
        return join(model, using: [type], leftKey: leftKey, rightKey: rightKey)
    }

    public init(_ fields: [QueryComponentsRepresentable]? = nil) {
        self.fields = fields ?? T.selectFields.map { T.field($0) }
    }
}

public protocol SelectQuery: FilteredQuery, FetchQuery {
    var joins: [Join] { get set }
    
    var fields: [QueryComponentsRepresentable] { get }
}

public extension SelectQuery {
    
    public var queryComponents: QueryComponents {
        var components = QueryComponents(components: [
            "SELECT",
            (fields.isEmpty) ? "*" : QueryComponents(components: fields.map{$0.queryComponents}, mergedByString: ","),
            "FROM",
            QueryComponents(tableName)
            ]
        )
        
        if !joins.isEmpty {
            components.append(joins.queryComponents)
        }
        
        if let condition = condition {
            components.append("WHERE")
            components.append(condition.queryComponents)
        }
        
        if !orderBy.isEmpty {
            components.append("ORDER BY")
            components.append(orderBy.queryComponents(mergedByString: ","))
        }

        if !groupBy.isEmpty {
            components.append("GROUP BY")
            components.append(groupBy.queryComponents(mergedByString: ","))
        }
        
        if let limit = limit {
            components.append(limit.queryComponents)
        }
        
        if let offset = offset {
            components.append(offset.queryComponents)
        }
        
        return components
    }
}

