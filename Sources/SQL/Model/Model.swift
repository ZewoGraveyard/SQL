//
//  Model.swift
//  SQL
//
//  Created by David Ask on 25/05/16.
//
//

public protocol ModelProtocol: Table, RowConvertible {
    associatedtype PrimaryKey: Hashable, ValueConvertible
    static var primaryKeyField: Field { get }
    
    func serialize() -> [Field: ValueConvertible?]
    
    mutating func willSave() throws
    mutating func didSave()
    
    mutating func willUpdate() throws
    mutating func didUpdate()
    
    mutating func willCreate() throws
    mutating func didCreate()
    
    mutating func willDelete() throws
    mutating func didDelete()
    
    mutating func willRefresh() throws
    mutating func didRefresh()
}

public extension ModelProtocol {
    public func willSave() throws {}
    public func didSave() {}
    
    public func willUpdate() throws {}
    public func didUpdate() {}
    
    public func willCreate() throws {}
    public func didCreate() {}
    
    public func willDelete() throws {}
    public func didDelete() {}
    
    public func willRefresh() throws {}
    public func didRefresh() {}
}

public extension ModelProtocol where Field.RawValue == String {
    static var qualifiedPrimaryKeyField: QualifiedField {
        return field(primaryKeyField)
    }
}

public struct EntityError: ErrorProtocol, CustomStringConvertible {
    public let description: String
    
    public init(_ description: String) {
        self.description = description
    }
}

public struct Entity<Model: ModelProtocol where Model.Field.RawValue == String>: Equatable {
    
    internal var primaryKey: Model.PrimaryKey?
    public var model: Model
    
    public init(model: Model, primaryKey: Model.PrimaryKey? = nil) {
        self.model = model
        self.primaryKey = primaryKey
    }
    
    public var persisted: Bool {
        return primaryKey != nil
    }
    
    public static func get<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(_ pk: Model.PrimaryKey, connection: T) throws -> Entity? {
        guard let row = try connection.execute(Model.select().filter(Model.qualifiedPrimaryKeyField == pk).first).first else {
            return nil
        }
        
        return Entity(model: try Model.init(row: row), primaryKey: try row.value(Model.qualifiedPrimaryKeyField))
    }
    
    public static func fetchAll<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(connection: T) throws -> [Entity] {
        return try fetch(where: nil, limit: nil, offset: nil, connection: connection)
    }
    
    public static func fetch<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(where predicate: Predicate? = nil, limit: Int? = 0, offset: Int? = 0, connection: T) throws -> [Entity] {
        let select = Model.select()
        
        if let predicate = predicate {
            select.filter(predicate)
        }
        
        if let limit = limit {
            select.limit(limit)
        }
        
        if let offset = offset {
            select.offset(offset)
        }
        
        return try connection.execute(select).map { Entity(model: try Model.init(row: $0), primaryKey: try $0.value(Model.qualifiedPrimaryKeyField)) }
    }
    
    mutating public func delete<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(connection: T) throws {
        guard let pk = primaryKey else {
            throw EntityError("Cannot delete a non-persisted model")
        }

        try connection.execute(Model.delete(where: Model.qualifiedPrimaryKeyField == pk))
        primaryKey = nil
    }
    
    mutating public func refresh<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(connection: T) throws {
        guard let pk = primaryKey else {
            throw EntityError("Cannot refresh a non-persisted model")
        }
        
        try model.willRefresh()
        guard let refreshed = try self.dynamicType.get(pk, connection: connection) else {
            throw EntityError("Failed to re-fetch model with primary key \(pk)")
        }
        
        self = refreshed
        model.didRefresh()
    }
    
    mutating public func create<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(connection: T) throws {
        guard !persisted else {
            throw EntityError("Cannot insert an already persisted model")
        }
        
        try connection.transaction {
            try self.model.willSave()
            try self.model.willCreate()
            
            let result = try connection.execute(Model.insert(self.model.serialize()).returning(Model.qualifiedPrimaryKeyField))
            
            guard let pk: Model.PrimaryKey = try result.first?.value(Model.qualifiedPrimaryKeyField) else {
                throw EntityError("Failed to retreieve primary key from insert statement")
            }
            
            self.primaryKey = pk
            
            self.model.didCreate()
            self.model.didSave()
            try self.refresh(connection: connection)
        }
    }
    
    mutating public func update<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(connection: T) throws {
        guard persisted else {
            throw EntityError("Cannot update a non-persisted model")
        }
        
        try model.willSave()
        try model.willUpdate()
        try connection.execute(Model.update(model.serialize()))
        try refresh(connection: connection)
        model.didUpdate()
        model.didSave()
    }
    
    mutating public func save<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(connection: T) throws {
        if persisted {
            try update(connection: connection)
        }
        else {
            try create(connection: connection)
        }
    }
}


public func == <M: ModelProtocol>(lhs: Entity<M>, rhs: Entity<M>) -> Bool {
    guard let lpk = lhs.primaryKey, rpk = rhs.primaryKey else {
        return false
    }
    
    return "\(lhs.model.dynamicType.tableName).\(lpk.hashValue)" == "\(rhs.model.dynamicType.tableName).\(rpk.hashValue)"
}