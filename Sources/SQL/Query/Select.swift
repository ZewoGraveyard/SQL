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
    public private(set) var fields: [QueryComponentRepresentable]
    
    public let tableName: String

    public var condition: Condition? = nil
    public var joins: [Join] = []
    public var offset: Offset? = nil

    public var limit: Limit? = nil
    public var orderBy: [OrderBy] = []
    public var group: GroupBy? = nil


    public init(fields: [QueryComponentRepresentable], from tableName: String) {
        self.tableName = tableName
        self.fields = fields
    }

    public init(_ fields: QueryComponentRepresentable..., from tableName: String) {
        self.init(fields: fields, from: tableName)
    }


    public init<T: Table>(_ fields: T.Field..., from table: T.Type ) {
        self.init(fields: fields.map {table.field($0)}, from: table.tableName)
    }


    public func select(fields: [QueryComponentRepresentable]) -> Select {
        var new = self
        new.fields.append(contentsOf: fields)
        return new
    }

    public func select(_ fields: QueryComponentRepresentable...) -> Select {
        return self.select(fields: fields)
    }


    public func join(_ tableClause: QueryComponentRepresentable, using type: [Join.JoinType],
                     leftKey: DeclaredField, rightKey: DeclaredField) -> Select {
        var new = self
        new.joins.append(
            Join(tableClause.queryComponent, type: type, leftKey: leftKey, rightKey: rightKey)
        )
        return new
    }
//
//    public func join(tableName: String, using type: Join.JoinType, leftKey: QueryComponentRepresentable, rightKey: QueryComponentRepresentable) -> Select {
//        return join(queryComponent(tableName), using: [type], leftKey: leftKey, rightKey: rightKey)
//    }
//
//    public func join(queryComponent: QueryComponentRepresentable, type: Join.JoinType, leftKey: QueryComponentRepresentable, rightKey: QueryComponentRepresentable) -> Select {
//        return join(queryComponent.queryComponent, using: [type], leftKey: leftKey, rightKey: rightKey)
//    }
}

extension Select {
    public func asSubquery(_ alias: String? = nil) -> Subquery {
        return Subquery(query: queryComponent, alias: alias)
    }
}

//public struct ModelSelect<T: Model>: SelectQuery, ModelQuery {
//    public typealias ModelType = T
//
//    public var tableName: String {
//        return T.tableName
//    }
//
//    public let fields: [QueryComponentRepresentable]
//
//    public var condition: Condition? = nil
//
//    public var joins: [Join] = []
//
//    public var offset: Offset? = nil
//
//    public var limit: Limit? = nil
//
//    public var orderBy: [OrderBy] = []
//
//    public var groupBy: [GroupBy] = []
//
//    public func join<R: Model>(model: R.Type, using type: [Join.JoinType], leftKey: ModelType.Field, rightKey: R.Field) -> ModelSelect<T> {
//        var new = self
//        new.joins.append(
//            Join(queryComponent(R.tableName), type: type, leftKey: ModelType.field(leftKey).qualifiedName, rightKey: R.field(rightKey).qualifiedName)
//        )
//
//        return new
//    }
//
//    public func join<R: Model>(model: R.Type, using type: Join.JoinType, leftKey: ModelType.Field, rightKey: R.Field) -> ModelSelect<T> {
//        return join(model, using: [type], leftKey: leftKey, rightKey: rightKey)
//    }
//
//    public init(_ fields: [QueryComponentRepresentable]? = nil) {
//        self.fields = fields ?? T.selectFields.map { T.field($0) }
//    }
//}

public protocol SelectQuery: FilteredQuery, FetchQuery {
    var joins: [Join] { get set }
//
    var fields: [QueryComponentRepresentable] { get }
}

public extension SelectQuery {
    public var queryComponent: QueryComponent {
        let fieldsComponents: [QueryComponent] = fields.map{$0.queryComponent}
        return .select(fields: fieldsComponents,
                from: .table(name: tableName, alias: nil),
                joins: joins.map{$0.queryComponent},
                filter: condition?.queryComponent,
                ordersBy: orderBy.map{ $0.queryComponent },
                offset: offset?.queryComponent,
                limit: limit?.queryComponent,
                groupBy: group?.queryComponent,
                having: nil
        )
    }
}

