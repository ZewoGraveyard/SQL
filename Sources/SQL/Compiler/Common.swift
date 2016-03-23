public class Compiler {

//    var stringParts: [String] = []

    public func compile(query: QueryComponent) -> [String] {

        switch query {
        case let .parts(parts):
            return compileParts(parts)
        case let .select(fields, parts):
            return select(fields, parts: parts)
        case let .field(name, table, alias):
            return field(name, table: table, alias: alias)
        case let .from(parts):
            return from(parts)
        case let .table(name, alias):
            return table(name, alias: alias)
        case let .subquery(query, alias):
            return subquery(query, alias: alias)
        default:
            print("default \(query)")
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

    func from(parts: QueryComponent) -> [String] {
        return ["from"] + compile(parts)
    }

    func field(name: String, table: String?, alias: String?) -> [String] {
        var string = name
        if let table = table {
            string += ".\(table)"
        }
        if let alias = alias {
            string += " as \(alias)"
        }
        return [string]
    }

    func table(name: String, alias: String?) -> [String] {
        var stringParts = [name, ]
        if let alias = alias {
            stringParts.append(contentsOf: ["as", alias])
        }
        return stringParts
    }

    func bind() {

    }

    func subquery(query: QueryComponent, alias: String?) -> [String] {
        var stringParts: [String] = ["("]
        stringParts.append(contentsOf: compile(query))
        stringParts.append(")")
        if let alias = alias {
            stringParts.append(contentsOf: ["as", alias])
        }
        return stringParts
    }

    func select(fields: QueryComponent, parts: QueryComponent) -> [String] {
        var stringParts = ["SELECT"]
        switch fields {
        case let .parts(fieldArray):
            for (index, field) in fieldArray.enumerated() {
                stringParts.append(contentsOf: compile(field))
                if index != fieldArray.count-1 {
                    stringParts.append(",")
                }
            }
            let parts = compile(parts)

            stringParts.append(contentsOf: parts)
            return stringParts
        default:
            return []
        }

    }

    func returning() {

    }

    func groupBy() {

    }


}