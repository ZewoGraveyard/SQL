public class Compiler {

    var sqlData: [SQLData] = []

    public func compile(query: QueryComponentRepresentable) -> (statement: String, params: [SQLData]) {

        let stringParts = compilePart(query.queryComponent)
        return (statement: stringParts.joined(separator: " "), params: sqlData)
    }

    func compilePart(query: QueryComponent) -> [String] {

        switch query {
        case let .sql(str):
            return [str]
        case let .parts(parts):
            return compileParts(parts)
        case let .select(fields, from, joins, filter, ordersBy, offset, limit, groupBy, having):
            return select(fields, from: from, joins: joins, filter: filter, ordersBy: ordersBy, offset: offset,
                    limit: limit, groupBy: groupBy, having: having)
        case let .column(name, table, alias):
            return column(name, table: table, alias: alias)
        case let .table(name, alias):
            return table(name, alias: alias)
        case let .subquery(query, alias):
            return subquery(query, alias: alias)
        case let .groupBy(fields):
            return groupBy(fields)
        case let .join(types, with, leftKey, rightKey):
            return join(types, with: with, leftKey: leftKey, rightKey: rightKey)
        case let .condition(cond):
            return compileCondition(cond)
        case let .bind(data):
            return bind(data)
        case let .delete(from, condition):
             return delete(from, condition: condition)
        case let .insert(into, values):
            return insert(into, values: values)
        default:
            print("default!!!!!!!!!!!!!!!!!!!!! \(query)")
            return []
        }
    }

    func compileParts(parts: [QueryComponent]) -> [String] {
        return parts.map {
            compilePart($0)
        }.flatMap {
            $0
        }
    }

    func compileParts(parts: [QueryComponent], withDivider divider: String) -> [String] {
        var stringParts: [String] = []
        let lastIndex = parts.count - 1
        for (index, part) in parts.enumerated() {
            stringParts.append(contentsOf: compilePart(part))
            if index != lastIndex {
                stringParts.append(divider)
            }
        }
        return stringParts
    }

    func compileParts<T>(parts: [T], withDivider divider: String, compileFunc: (T -> [String])) -> [String] {
        var stringParts: [String] = []
        let lastIndex = parts.count - 1
        for (index, part) in parts.enumerated() {
            stringParts.append(contentsOf: compileFunc(part))
            if index != lastIndex {
                stringParts.append(divider)
            }
        }
        return stringParts
    }

    func column(name: String, table: String?, alias: String?) -> [String] {
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

    func bind(data: SQLData) -> [String] {
        sqlData.append(data)
        return ["%s"]
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
        stringParts.append(contentsOf: compilePart(with))
        stringParts.append("ON")
        stringParts.append(contentsOf: compilePart(leftKey))
        stringParts.append("=")
        stringParts.append(contentsOf: compilePart(rightKey))
        return stringParts
    }

    func subquery(query: QueryComponent, alias: String?) -> [String] {
        var stringParts: [String] = ["("]
        stringParts.append(contentsOf: compilePart(query))
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


        stringParts.append(contentsOf: compileParts(fields, withDivider: ","))

        stringParts.append("FROM")
        stringParts.append(contentsOf: compilePart(from))

        for join in joins {
            stringParts.append(contentsOf: compilePart(join))
        }

        if let filter = filter {
            stringParts.append("WHERE")
            stringParts.append(contentsOf: compilePart(filter))
        }

        if (offset != nil || limit != nil) {
            stringParts = offsetLimit(stringParts, offset: offset, limit: limit)
        }

        return stringParts
    }

    func ordersBy(ordersBy: [QueryComponent]) {

    }


    func compileCondition(condition: Condition) -> [String] {
        func statementWithKeyValue(key: QueryComponentRepresentable, _ op: String, _ value: QueryComponentRepresentable) -> [String] {
            var stringParts: [String] = []
            stringParts.append(contentsOf: compilePart(key.queryComponent))
            stringParts.append(op)
            stringParts.append(contentsOf: compilePart(value.queryComponent))
            return stringParts
        }

        switch condition {
        case .Equals(let key, let value):
            return statementWithKeyValue(key, "=", value)

        case .GreaterThan(let key, let value):
            return statementWithKeyValue(key, ">", value)

        case .GreaterThanOrEquals(let key, let value):
            return statementWithKeyValue(key, ">=", value)

        case .LessThan(let key, let value):
            return statementWithKeyValue(key, "<", value)

        case .LessThanOrEquals(let key, let value):
            return statementWithKeyValue(key, "<=", value)

//        case .In(let key, let values):
//
//            var strings = [String]()
//
//            for _ in values {
//                strings.append(queryComponent.valuePlaceholder)
//            }
//
//            return queryComponent("\(key) IN(\(strings.joined(separator: ", ")))", values: values)
//
//        case .NotIn(let key, let values):
//            return (!Condition.In(key, values)).queryComponent

        case .And(let conditions):
            var stringParts = ["("]
            stringParts.append(contentsOf: compileParts(conditions, withDivider: "AND", compileFunc: compileCondition))
            stringParts.append(")")
            return stringParts

        case .Or(let conditions):
            var stringParts = ["("]
            stringParts.append(contentsOf: compileParts(conditions, withDivider: "OR", compileFunc: compileCondition))
            stringParts.append(")")
            return stringParts
        case .Not(let cond):
            var stringParts = ["NOT", "("]
            stringParts.append(contentsOf: compileCondition(cond))
            stringParts.append(")")

            return stringParts
        default:
            return []
//        case .Like(let key, let value):
//            return queryComponent(strings: [key.qualifiedName, "LIKE", queryComponent.valuePlaceholder], values: [value])
        }
    }

    func offsetLimit(selectQuery: [String], offset: QueryComponent?, limit: QueryComponent?) -> [String] {
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
        stringParts.append(contentsOf: compileParts(fields, withDivider: ","))
        return stringParts
    }

    func delete(from: QueryComponent, condition: QueryComponent?) -> [String] {
        var stringParts = ["DELETE FROM"]
        stringParts.append(contentsOf: compilePart(from))
        if let condition = condition {
            stringParts.append("WHERE")
            stringParts.append(contentsOf: compilePart(condition))
        }
        return stringParts
    }
    func insert(into: QueryComponent, values: QueryComponent) -> [String] {
        var stringParts = ["INSERT INTO"]
        stringParts.append(contentsOf: compilePart(into))
        return stringParts
    }

}