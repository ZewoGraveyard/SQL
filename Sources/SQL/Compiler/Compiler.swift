public class Compiler {

//    var stringParts: [String] = []

    public func compile(query: QueryComponent) -> [String] {

        switch query {
        case let .parts(parts):
            return compileParts(parts)
        case let .select(fields, from, joins, filter, ordersBy, offset, limit, groupBy, having):
            return select(fields, from: from, joins: joins, filter: filter, ordersBy: ordersBy, offset: offset,
                    limit: limit, groupBy: groupBy, having: having)
        case let .field(name, table, alias):
            return field(name, table: table, alias: alias)
        case let .table(name, alias):
            return table(name, alias: alias)
        case let .subquery(query, alias):
            return subquery(query, alias: alias)
        case let .groupBy(fields):
            return groupBy(fields)
        case let .join(types, with, leftKey, rightKey):
            return join(types, with: with, leftKey: leftKey, rightKey: rightKey)

        default:
            print("default!!!!!!!!!!!!!!!!!!!!! \(query)")
            return []
        }
    }

    func compileParts(parts: [QueryComponent]) -> [String] {
        let stringParts = parts.map {
            compile($0)
        }
        return stringParts.flatMap {
            $0
        }
    }

    func field(name: String, table: String?, alias: String?) -> [String] {
        var stringParts: [String] = []
        if let table = table {
            stringParts.append("\(table).\(name)")
        } else {
            stringParts.append(name)
        }
        if let alias = alias {
            stringParts.append(contentsOf: ["as", alias])
        }
        return stringParts
    }

    func table(name: String, alias: String?) -> [String] {
        var stringParts = [name, ]
        if let alias = alias {
            stringParts.append(contentsOf: ["AS", alias])
        }
        return stringParts
    }

    func bind() {

    }

    func joinType(type: Join.JoinType) -> String {
        switch type {
        case .Inner:
            return "INNER"
        case .Left:
            return "LEFT"
        case .Outer:
            return "OUTER"
        case .Right:
            return "RIGHT"
        }
    }

    func join(types: [Join.JoinType], with: QueryComponent, leftKey: QueryComponent, rightKey: QueryComponent) -> [String] {
        var stringParts: [String] = []
        stringParts.append(contentsOf: types.map {
            joinType($0)
        })
        stringParts.append("JOIN")
        stringParts.append(contentsOf: compile(with))
        stringParts.append("ON")
        stringParts.append(contentsOf: compile(leftKey))
        stringParts.append("=")
        stringParts.append(contentsOf: compile(rightKey))
        return stringParts
    }

    func subquery(query: QueryComponent, alias: String?) -> [String] {
        var stringParts: [String] = ["("]
        stringParts.append(contentsOf: compile(query))
        stringParts.append(")")
        if let alias = alias {
            stringParts.append(contentsOf: ["AS", alias])
        }
        return stringParts
    }

    func select(fields: [QueryComponent], from: QueryComponent, joins: [QueryComponent],
                filter: QueryComponent?, ordersBy: [QueryComponent], offset: QueryComponent?,
                limit: QueryComponent?, groupBy: QueryComponent?, having: QueryComponent?) -> [String] {


        var stringParts = ["SELECT"]
        for (index, field) in fields.enumerated() {
            stringParts.append(contentsOf: compile(field))
            if index != fields.count - 1 {
                stringParts.append(",")
            }
        }

        stringParts.append("FROM")
        stringParts.append(contentsOf: compile(from))

        for join in joins {
            stringParts.append(contentsOf: compile(join))
        }
        if (offset != nil || limit != nil) {
            stringParts = offsetLimit(stringParts, offset: offset, limit: limit)
        }

        return stringParts
    }

    func ordersBy(ordersBy: [QueryComponent]){

    }

    func offsetLimit(selectQuery: [String], offset: QueryComponent?, limit: QueryComponent?) -> [String]  {
        var stringParts = selectQuery
        if case let .limit(num)? = limit {
            stringParts.append("LIMIT \(num)")
        }
        if case let .offset(num)? = offset {
            stringParts.append("OFFSET \(num)")
        }
        return stringParts

    }

    func returning() {

    }

    func groupBy(fields: [QueryComponent]) -> [String] {
        var stringParts = ["GROUP BY"]
        for (index, field) in fields.enumerated() {
            stringParts.append(contentsOf: compile(field))
            if index != fields.count - 1 {
                stringParts.append(",")
            }
        }
        return stringParts
    }


}