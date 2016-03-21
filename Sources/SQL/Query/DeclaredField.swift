


public struct DeclaredField: CustomStringConvertible {
    public let unqualifiedName: String
    public var tableName: String?
    private var aliasName: String?
    public init(name: String, tableName: String? = nil, alias aliasName: String? = nil) {
        self.unqualifiedName = name
        self.tableName = tableName
        self.aliasName = aliasName
    }
}

extension DeclaredField: Hashable {
    public var hashValue: Int {
        return qualifiedName.hashValue
    }
}

public func field(name: String) -> DeclaredField {
    return DeclaredField(name: name)
}

public extension Sequence where Iterator.Element == DeclaredField {
    public func queryComponentsForSelectingFields(useQualifiedNames useQualified: Bool, useAliasing aliasing: Bool, isolateQueryComponents isolate: Bool) -> QueryComponents {
        let string = map {
            field in

            var str = useQualified ? field.qualifiedName : field.unqualifiedName

            if aliasing && field.qualifiedName != field.alias {
                str += " AS \(field.alias)"
            }

            return str
        }.joined(separator: ", ")

        if isolate {
            return QueryComponents(string).isolate()
        }
        else {
            return QueryComponents(string)
        }
    }
}

public extension Collection where Iterator.Element == (DeclaredField, Optional<SQLData>) {
    public func queryComponentsForSettingValues(useQualifiedNames useQualified: Bool) -> QueryComponents {
        let string = map {
            (field, value) in

            var str = useQualified ? field.qualifiedName : field.unqualifiedName

            str += " = " + QueryComponents.valuePlaceholder

            return str

        }.joined(separator: ", ")

        return QueryComponents(string, values: map { $0.1 })
    }

    public func queryComponentsForValuePlaceHolders(isolated isolate: Bool) -> QueryComponents {
        let string = map {
            (_, value) in
                guard let value = value else {
                    return QueryComponents.valuePlaceholder
                }
                switch value {
                case let .RawSQL(rawSql):
                    return rawSql
                default:
                    return QueryComponents.valuePlaceholder
                }
        }.joined(separator: ", ")

        let components = QueryComponents(string, values: map { $0.1 })

        return isolate ? components.isolate() : components
    }
}

public func == (lhs: DeclaredField, rhs: DeclaredField) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public extension DeclaredField {

    public var qualifiedName: String {
        guard let tableName = tableName else {
            return unqualifiedName
        }

        return tableName + "." + unqualifiedName
    }

    public var alias: String {
        if let aliasName = aliasName {
            return aliasName
        }
        guard let tableName = tableName else {
            return unqualifiedName
        }

        return tableName + "__" + unqualifiedName
    }

    public func alias(newAliasName: String) -> DeclaredField {
        var new = self
        new.aliasName = newAliasName
        return new
    }

    public var description: String {
        return qualifiedName
    }

    public func containedIn<T: SQLDataConvertible>(values: [T?]) -> Condition {
        return .In(self, values.map { $0?.sqlData })
    }

    public func containedIn<T: SQLDataConvertible>(values: T?...) -> Condition {
        return .In(self, values.map { $0?.sqlData })
    }

    public func notContainedIn<T: SQLDataConvertible>(values: [T?]) -> Condition {
        return .NotIn(self, values.map { $0?.sqlData })
    }

    public func notContainedIn<T: SQLDataConvertible>(values: T?...) -> Condition {
        return .NotIn(self, values.map { $0?.sqlData })
    }

    public func equals<T: SQLDataConvertible>(value: T?) -> Condition {
        return .Equals(self, .Value(value?.sqlData))
    }

    public func like<T: SQLDataConvertible>(value: T?) -> Condition {
        return .Like(self, value?.sqlData)
    }
}

public func == <T: SQLDataConvertible>(lhs: DeclaredField, rhs: T?) -> Condition {
    return lhs.equals(rhs)
}

public func == (lhs: DeclaredField, rhs: DeclaredField) -> Condition {
    return .Equals(lhs, .Property(rhs))
}

public func > <T: SQLDataConvertible>(lhs: DeclaredField, rhs: T?) -> Condition {
    return .GreaterThan(lhs, .Value(rhs?.sqlData))
}

public func > (lhs: DeclaredField, rhs: DeclaredField) -> Condition {
    return .GreaterThan(lhs, .Property(rhs))
}


public func >= <T: SQLDataConvertible>(lhs: DeclaredField, rhs: T?) -> Condition {
    return .GreaterThanOrEquals(lhs, .Value(rhs?.sqlData))
}

public func >= (lhs: DeclaredField, rhs: DeclaredField) -> Condition {
    return .GreaterThanOrEquals(lhs, .Property(rhs))
}


public func < <T: SQLDataConvertible>(lhs: DeclaredField, rhs: T?) -> Condition {
    return .LessThan(lhs, .Value(rhs?.sqlData))
}

public func < (lhs: DeclaredField, rhs: DeclaredField) -> Condition {
    return .LessThan(lhs, .Property(rhs))
}


public func <= <T: SQLDataConvertible>(lhs: DeclaredField, rhs: T?) -> Condition {
    return .LessThanOrEquals(lhs, .Value(rhs?.sqlData))
}

public func <= (lhs: DeclaredField, rhs: DeclaredField) -> Condition {
    return .LessThanOrEquals(lhs, .Property(rhs))
}


public protocol FieldType: RawRepresentable, Hashable {
    var rawValue: String { get }
}
