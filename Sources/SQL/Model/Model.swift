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

public func field(_ name: String) -> DeclaredField {
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
        var strings = [String]()
        
    
        indices.forEach { _ in
            strings.append(QueryComponents.valuePlaceholder)
        }
        
        let string = strings.joined(separator: ", ")
        
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

    public func containedIn<T: SQLDataConvertible>(_ values: [T?]) -> Condition {
        return .In(self, values.map { $0?.sqlData })
    }

    public func containedIn<T: SQLDataConvertible>(_ values: T?...) -> Condition {
        return .In(self, values.map { $0?.sqlData })
    }

    public func notContainedIn<T: SQLDataConvertible>(_ values: [T?]) -> Condition {
        return .NotIn(self, values.map { $0?.sqlData })
    }

    public func notContainedIn<T: SQLDataConvertible>(_ values: T?...) -> Condition {
        return .NotIn(self, values.map { $0?.sqlData })
    }
    
    public func equals<T: SQLDataConvertible>(_ value: T?) -> Condition {
        return .Equals(self, .Value(value?.sqlData))
    }
    
    public func like<T: SQLDataConvertible>(_ value: T?) -> Condition {
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


public protocol FieldProtocol: RawRepresentable, Hashable {
    var rawValue: String { get }
}


public struct ModelError: ErrorProtocol {
    public let description: String
    
    public init(description: String) {
        self.description = description
    }
}

public enum ModelChangeStatus {
    case Unknown
    case Changed
    case Unchanged
}

public protocol Model {
    associatedtype Field: FieldProtocol
    associatedtype PrimaryKey: SQLDataConvertible
    
    var primaryKey: PrimaryKey? { get }
    static var fieldForPrimaryKey: Field { get }
    
    static var tableName: String { get }
    
    static var selectFields: [Field] { get }
    
    var changedFields: [Field]? { get set }
   
    var persistedValuesByField: [Field: SQLDataConvertible?] { get }
    
    func willSave()
    func didSave()
    
    func willUpdate()
    func didUpdate()
    
    func willCreate()
    func didCreate()
    
    func willDelete()
    func didDelete()
    
    func willRefresh()
    func didRefresh()
    
    func validate() throws
    
    init(row: Row) throws
}

public extension Model {
    
    public static var selectFields: [Field] {
        return []
    }
    
    public static var selectQuery: ModelSelect<Self> {
        return ModelSelect()
    }
    
    public static func updateQuery(_ values: [Field: SQLDataConvertible?] = [:]) -> ModelUpdate<Self> {
        return ModelUpdate(values)
    }
    
    public static var deleteQuery: ModelDelete<Self> {
        return ModelDelete()
    }
    
    public static func insertQuery(values: [Field: SQLDataConvertible?]) -> ModelInsert<Self> {
        return ModelInsert(values)
    }
    
    public mutating func setNeedsSave(field: Field) throws {
        guard var changedFields = changedFields else {
            throw ModelError(description: "Cannot set changed value, as property `changedFields` is nil")
        }
        
        guard !changedFields.contains(field) else {
            return
        }
        
        changedFields.append(field)
        self.changedFields = changedFields
    }
    
    public var changedFields: [Self.Field]? {
        get { return nil }
        set { return }
    }
    
    public var hasChanged: ModelChangeStatus {
        guard let changedFields = changedFields else {
            return .Unknown
        }
        
        return changedFields.isEmpty ? .Unchanged : .Changed
    }
    
    public var changedValuesByField: [Field: SQLDataConvertible?]? {
        guard let changedFields = changedFields else {
            return nil
        }
        
        var dict = [Field: SQLDataConvertible?]()
        
        var values = persistedValuesByField
        
        for field in changedFields {
            dict[field] = values[field]
        }
        
        return dict
    }
    
    public var persistedFields: [Field] {
        return Array(persistedValuesByField.keys)
    }

    public static func field(_ field: Field) -> DeclaredField {
        return DeclaredField(name: field.rawValue, tableName: Self.tableName)
    }
    
    public static func field(_ field: String) -> DeclaredField {
        return DeclaredField(name: field, tableName: Self.tableName)
    }
    
    public var isPersisted: Bool {
        return primaryKey != nil
    }
    
    public static var declaredPrimaryKeyField: DeclaredField {
        return field(fieldForPrimaryKey)
    }
    
    public static var declaredSelectFields: [DeclaredField] {
        return selectFields.map { Self.field($0) }
    }
    
    public static func get<T: ConnectionProtocol where T.Result.Iterator.Element == Row>(_ pk: Self.PrimaryKey, connection: T) throws -> Self? {
        return try selectQuery.filter(declaredPrimaryKeyField == pk).first(connection)
    }
    
    mutating func create<T: ConnectionProtocol where T.Result.Iterator.Element == Row>(_ connection: T) throws {
        guard !isPersisted else {
            throw ModelError(description: "Cannot create an already persisted model.")
        }
        
        let pk: PrimaryKey = try connection.executeInsertQuery(query: self.dynamicType.insertQuery(values: persistedValuesByField), returningPrimaryKeyForField: self.dynamicType.declaredPrimaryKeyField)
        
        guard let newSelf = try self.dynamicType.get(pk, connection: connection) else {
            throw ModelError(description: "Failed to find model of supposedly inserted id \(pk)")
        }
        
        willSave()
        willCreate()
        self = newSelf
        didCreate()
        didSave()
    }
    
    public mutating func refresh<T: ConnectionProtocol where T.Result.Iterator.Element == Row>(_ connection: T) throws {
        guard let pk = primaryKey, newSelf = try Self.get(pk, connection: connection) else {
            throw ModelError(description: "Cannot refresh a non-persisted model. Please use insert() or save() first.")
        }
        
        willRefresh()
        self = newSelf
        didRefresh()
    }
    
    public mutating func update<T: ConnectionProtocol where T.Result.Iterator.Element == Row>(_ connection: T) throws {
        guard let pk = primaryKey else {
            throw ModelError(description: "Cannot update a model that isn't persisted. Please use insert() first or save()")
        }
        
        let values = changedValuesByField ?? persistedValuesByField
        
        guard !values.isEmpty else {
            throw ModelError(description: "Nothing to save")
        }
        
        try validate()
        
        willSave()
        willUpdate()
        try Self.updateQuery(values).filter(Self.declaredPrimaryKeyField == pk).execute(connection)
        didUpdate()
        try self.refresh(connection)
        didSave()
    }
    
    public mutating func delete<T: ConnectionProtocol>(_ connection: T) throws {
        guard let pk = self.primaryKey else {
            throw ModelError(description: "Cannot delete a model that isn't persisted.")
        }
        
        willDelete()
        try Self.deleteQuery.filter(Self.declaredPrimaryKeyField == pk).execute(connection)
        didDelete()
    }

    public mutating func save<T: ConnectionProtocol where T.Result.Iterator.Element == Row>(_ connection: T) throws {
        
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

public extension Model {
    public func willSave() {}
    public func didSave() {}
    
    public func willUpdate() {}
    public func didUpdate() {}
    
    public func willCreate() {}
    public func didCreate() {}
    
    public func willDelete() {}
    public func didDelete() {}
    
    public func willRefresh() {}
    public func didRefresh() {}
    
    public func validate() throws {}
}