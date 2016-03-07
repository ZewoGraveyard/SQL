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



public struct DeclaredField: CustomStringConvertible {
    public let unqualifiedName: String
    public var tableName: String?
    
    public init(name: String, tableName: String? = nil) {
        self.unqualifiedName = name
        self.tableName = tableName
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

public struct ModelError: ErrorType {
    public let description: String
    
    public init(description: String) {
        self.description = description
    }
}

public enum ModelDirtyStatus {
    case Unknown
    case Dirty
    case Clean
}

public protocol Model {
    associatedtype Field: FieldType
    associatedtype PrimaryKeyType: SQLDataConvertible
    
    var primaryKey: PrimaryKeyType? { get }
    static var fieldForPrimaryKey: Field { get }
    
    static var tableName: String { get }
    
    static var selectFields: [Field] { get }
    
    var dirtyFields: [Field]? { get set }
   
    var persistedValuesByField: [Field: SQLDataConvertible?] { get }
    
    mutating func create<T: Connection where T.ResultType.Generator.Element == Row>(connection: T) throws
    
    static func create<T: SQL.Connection where T.ResultType.Generator.Element == Row>(values: [Field: SQLDataConvertible?], connection: T) throws -> Self
    
    init(row: Row) throws
}

public extension Model {
    

    static var select: ModelSelect<Self> {
        return ModelSelect()
    }
    
    static func update(values: [Field: SQLDataConvertible?] = [:]) -> ModelUpdate<Self> {
        return ModelUpdate(values)
    }
    
    static var delete: ModelDelete<Self> {
        return ModelDelete()
    }
    
    mutating func setNeedsSaveForField(field: Field) throws {
        guard var dirtyFields = dirtyFields else {
            throw ModelError(description: "Cannot set dirty value, as property `dirtyFields` is nil")
        }
        
        guard !dirtyFields.contains(field) else {
            return
        }
        
        dirtyFields.append(field)
        self.dirtyFields = dirtyFields
    }
    
    public var dirtyFields: [Self.Field]? {
        get {
            return nil
        }
        set {
            return
        }
    }
    
    public var isDirty: ModelDirtyStatus {
        guard let dirtyFields = dirtyFields else {
            return .Unknown
        }
        
        return dirtyFields.isEmpty ? .Clean : .Dirty
    }
    
    public var dirtyValuesByField: [Field: SQLDataConvertible?]? {
        guard let dirtyFields = dirtyFields else {
            return nil
        }
        
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
            throw ModelError(description: "Cannot refresh a non-persisted model. Please use insert() or save() first.")
        }
        self = newSelf
    }
    
    mutating func update<T: Connection where T.ResultType.Generator.Element == Row>(connection: T) throws {
        guard let pk = primaryKey else {
            throw ModelError(description: "Cannot update a model that isn't persisted. Please use insert() first or save()")
        }
        
        let fields = dirtyValuesByField ?? persistedValuesByField
        
        guard !fields.isEmpty else {
            throw ModelError(description: "Nothing to save")
        }
        
        try Self.update(fields).filter(Self.declaredPrimaryKeyField == pk).execute(connection)
        try self.refresh(connection)
    }
    
    mutating func delete<T: Connection where T.ResultType.Generator.Element == Row>(connection: T) throws {
        guard let pk = self.primaryKey else {
            throw ModelError(description: "Cannot delete a model that isn't persisted.")
        }
        
        try Self.delete.filter(Self.declaredPrimaryKeyField == pk).execute(connection)
    }

    mutating func save<T: Connection where T.ResultType.Generator.Element == Row>(connection: T) throws {
        if isPersisted {
            try update(connection)
        }
        else {
            try create(connection)
            guard isPersisted else {
                fatalError("Primary key not set after insert. This is a serious error in an SQL adapter. Please consult a developer.")
            }
        }
    }

}