


public struct DeclaredField: CustomStringConvertible {
    public let name: String
    public var tableName: String?
    private var aliasName: String?
    public init(name: String, tableName: String? = nil, alias aliasName: String? = nil) {
        self.name = name
        self.tableName = tableName
        self.aliasName = aliasName
    }
    public var description: String {
        return name
    }

    public var qualifiedName: String {
        return name
    }
    public var unqualifiedName: String {
        return name
    }
    public var alias: String {
        return name
    }
}

extension DeclaredField: QueryComponentRepresentable {
    public var queryComponent: QueryComponent {
        return .column(name: name, table: tableName, alias: aliasName)
    }
}

extension DeclaredField: SQLDataRepresentable {
    public var sqlData: SQLData {
        return .Query(self.queryComponent)
    }
}

extension DeclaredField: StringLiteralConvertible {
    public init(stringLiteral value: String) {
        self.init(name: value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

extension DeclaredField: Hashable {
    public var hashValue: Int {
        return name.hashValue
    }
}

public func field(name: String) -> DeclaredField {
    return DeclaredField(name: name)
}

//public extension Sequence where Iterator.Element == DeclaredField {
//    public func queryComponentForSelectingFields(useQualifiedNames useQualified: Bool, useAliasing aliasing: Bool, isolatequeryComponent isolate: Bool) -> queryComponent {
//        let string = map {
//            field in
//
//            var str = useQualified ? field.qualifiedName : field.unqualifiedName
//
//            if aliasing && field.qualifiedName != field.alias {
//                str += " AS \(field.alias)"
//            }
//
//            return str
//        }.joined(separator: ", ")
//
//        if isolate {
//            return queryComponent(string).isolate()
//        }
//        else {
//            return queryComponent(string)
//        }
//    }
//}
//
//public extension Collection where Iterator.Element == (DeclaredField, Optional<SQLData>) {
//    public func queryComponentForSettingValues(useQualifiedNames useQualified: Bool) -> queryComponent {
//        let string = map {
//            (field, value) in
//
//            var str = useQualified ? field.qualifiedName : field.unqualifiedName
//
//            str += " = " + queryComponent.valuePlaceholder
//
//            return str
//
//        }.joined(separator: ", ")
//
//        return queryComponent(string, values: map { $0.1 })
//    }
//
//    public func queryComponentForValuePlaceHolders(isolated isolate: Bool) -> queryComponent {
//        let string = map {
//            (_, value) in
//                guard let value = value else {
//                    return queryComponent.valuePlaceholder
//                }
//                switch value {
//                case let .RawSQL(rawSql):
//                    return rawSql
//                default:
//                    return queryComponent.valuePlaceholder
//                }
//        }.joined(separator: ", ")
//
//        let components = queryComponent(string, values: map { $0.1 })
//
//        return isolate ? components.isolate() : components
//    }
//}
//
public func == (lhs: DeclaredField, rhs: DeclaredField) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
//
//public extension DeclaredField {
//
//    public var qualifiedName: String {
//        guard let tableName = tableName else {
//            return unqualifiedName
//        }
//
//        return tableName + "." + unqualifiedName
//    }
//
//    public var alias: String {
//        if let aliasName = aliasName {
//            return aliasName
//        }
////        guard let tableName = tableName else { //todo fix it
//        return unqualifiedName
////        }
//
////        return tableName + "__" + unqualifiedName
//    }
//
//    public func alias(newAliasName: String) -> DeclaredField {
//        var new = self
//        new.aliasName = newAliasName
//        return new
//    }
//
//    public var description: String {
//        return qualifiedName
//    }
//
//    public func containedIn<T: SQLDataRepresentable>(values: [T?]) -> Condition {
//        return .In(self, values.map { $0?.sqlData })
//    }
//
//    public func containedIn<T: SQLDataRepresentable>(values: T?...) -> Condition {
//        return .In(self, values.map { $0?.sqlData })
//    }
//
//    public func notContainedIn<T: SQLDataRepresentable>(values: [T?]) -> Condition {
//        return .NotIn(self, values.map { $0?.sqlData })
//    }
//
//    public func notContainedIn<T: SQLDataRepresentable>(values: T?...) -> Condition {
//        return .NotIn(self, values.map { $0?.sqlData })
//    }
//
//    public func equals<T: SQLDataRepresentable>(value: T?) -> Condition {
//        return .Equals(self, .Value(value?.sqlData))
//    }
//
//    public func like<T: SQLDataRepresentable>(value: T?) -> Condition {
//        return .Like(self, value?.sqlData)
//    }
//}
//
public func == <T: SQLDataRepresentable>(lhs: DeclaredField, rhs: T) -> Condition {
    return .Equals(lhs, rhs.sqlData)
}

public func == (lhs: DeclaredField, rhs: SQLData) -> Condition {
    if case .Null = rhs {
        return .Is(lhs, rhs)
    } else {
        return .Equals(lhs, rhs)
    }
}

//
//public func > <T: SQLDataRepresentable>(lhs: DeclaredField, rhs: T?) -> Condition {
//    return .GreaterThan(lhs, .Value(rhs?.sqlData))
//}
//
//public func > (lhs: DeclaredField, rhs: DeclaredField) -> Condition {
//    return .GreaterThan(lhs, .Property(rhs))
//}
//
//
//public func >= <T: SQLDataRepresentable>(lhs: DeclaredField, rhs: T?) -> Condition {
//    return .GreaterThanOrEquals(lhs, .Value(rhs?.sqlData))
//}
//
//public func >= (lhs: DeclaredField, rhs: DeclaredField) -> Condition {
//    return .GreaterThanOrEquals(lhs, .Property(rhs))
//}
//
//
//public func < <T: SQLDataRepresentable>(lhs: DeclaredField, rhs: T?) -> Condition {
//    return .LessThan(lhs, .Value(rhs?.sqlData))
//}
//
//public func < (lhs: DeclaredField, rhs: DeclaredField) -> Condition {
//    return .LessThan(lhs, .Property(rhs))
//}
//
//
//public func <= <T: SQLDataRepresentable>(lhs: DeclaredField, rhs: T?) -> Condition {
//    return .LessThanOrEquals(lhs, .Value(rhs?.sqlData))
//}
//
//public func <= (lhs: DeclaredField, rhs: DeclaredField) -> Condition {
//    return .LessThanOrEquals(lhs, .Property(rhs))
//}
//
//
public protocol FieldType: RawRepresentable, Hashable {
    var rawValue: String { get }
}
