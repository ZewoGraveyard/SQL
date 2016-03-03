// Model.swift
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



public struct DeclaredField: CustomStringConvertible, StringLiteralConvertible {
    public let unqualifiedName: String
    public var tableName: String?
    
    public init(name: String, tableName: String? = nil) {
        self.unqualifiedName = name
        self.tableName = tableName
    }
    
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
        return qualifiedName.hashValue
    }
}

public extension SequenceType where Generator.Element == DeclaredField {
    public func queryComponentsForSelectingFields(useQualifiedNames useQualified: Bool, useAliasing aliasing: Bool, isolateQueryComponents isolate: Bool) -> QueryComponents {
        let string = map {
            field in
            
            var str = useQualified ? field.qualifiedName : field.unqualifiedName
            
            if aliasing && field.qualifiedName != field.alias {
                str += " AS \(field.alias)"
            }
            
            return str
        }.joinWithSeparator(", ")
        
        if isolate {
            return QueryComponents(string).isolate()
        }
        else {
            return QueryComponents(string)
        }
    }
}

public extension CollectionType where Generator.Element == (DeclaredField, Optional<SQLData>) {
    public func queryComponentsForSettingValues(useQualifiedNames useQualified: Bool) -> QueryComponents {
        let string = map {
            (field, value) in
            
            var str = useQualified ? field.qualifiedName : field.unqualifiedName
            
            str += " = " + QueryComponents.valuePlaceholder
            
            return str
            
            }.joinWithSeparator(", ")
        
        return QueryComponents(string, values: map { $0.1 })
    }
    
    public func queryComponentsForValuePlaceHolders(isolated isolate: Bool) -> QueryComponents {
        var strings = [String]()
        
        for _ in startIndex..<endIndex {
            strings.append(QueryComponents.valuePlaceholder)
        }
        
        let string = strings.joinWithSeparator(", ")
        
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
        guard let tableName = tableName else {
            return unqualifiedName
        }
        
        return tableName + "__" + unqualifiedName
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

public struct ModelError: ErrorType {
    let description: String
}

public protocol Model {
    associatedtype Field: FieldType
    associatedtype PrimaryKeyType: SQLDataConvertible
    
    var primaryKey: PrimaryKeyType? { get }
    static var fieldForPrimaryKey: Field { get }
    
    static var tableName: String { get }
    
    static var selectFields: [Field] { get }
    
    var dirtyFields: [Field] { get set }
   
    var persistedValuesByField: [Field: SQLDataConvertible?] { get }
    
    mutating func insert<T: Connection where T.ResultType.Generator.Element == Row>(connection: T) throws
    
    init(row: Row) throws
}

public extension Model {
    

    static var select: ModelSelect<Self> {
        return ModelSelect()
    }
    
    static func update(values: [Field: SQLDataConvertible?] = [:]) -> ModelUpdate<Self> {
        return ModelUpdate(values)
    }
    
    static func insert(set values: [Field: SQLDataConvertible?]) -> ModelInsert<Self> {
        return ModelInsert(values)
    }
    
    static func delete() -> ModelDelete<Self> {
        return ModelDelete()
    }
    
    mutating func setNeedsSaveForField(field: Field) {
        guard !dirtyFields.contains(field) else {
            return
        }
        
        dirtyFields.append(field)
    }
    
    public var dirtyValuesByField: [Field: SQLDataConvertible?] {
        var dict = [Field: SQLDataConvertible?]()
        
        var values = persistedValuesByField
        
        for field in dirtyFields {
            dict[field] = values[field]
        }
        
        return dict
    }
    
    var persistedFields: [Field] {
        return Array(persistedValuesByField.keys)
    }

    public static func field(field: Field) -> DeclaredField {
        return DeclaredField(name: field.rawValue, tableName: Self.tableName)
    }
    
    public static func field(field: String) -> DeclaredField {
        return DeclaredField(name: field, tableName: Self.tableName)
    }
    
    public var isPersisted: Bool {
        return primaryKey != nil
    }
    
    public static var declaredPrimaryKeyField: DeclaredField {
        return field(fieldForPrimaryKey)
    }
    
    static func find<T: Connection where T.ResultType.Generator.Element == Row>(pk: Self.PrimaryKeyType, connection: T) throws -> Self? {
        return try ModelSelect().filter(declaredPrimaryKeyField == pk).first(connection)
    }
    
    mutating func refresh<T: Connection where T.ResultType.Generator.Element == Row>(connection: T) throws {
        guard let pk = primaryKey, newSelf = try Self.find(pk, connection: connection) else {
            throw ModelError(description: "Cannot update a non-persisted model. Please use insert() or save()")
        }
        self = newSelf
    }
    
    mutating func update<T: Connection where T.ResultType.Generator.Element == Row>(connection: T) throws {
        let fields = dirtyFields.isEmpty ? persistedValuesByField : dirtyValuesByField
        
        try Self.update(fields).execute(connection)
        try self.refresh(connection)
    }

    mutating func save<T: Connection where T.ResultType.Generator.Element == Row>(connection: T) throws {
        if isPersisted {
            try update(connection)
        }
        else {
            try insert(connection)
            guard isPersisted else {
                fatalError("Primary key not set after insert. This is a serious error in an SQL adapter. Please consult a developer.")
            }
        }
    }

}