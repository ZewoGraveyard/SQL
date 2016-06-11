//
//  Model.swift
//  SQL
//
//  Created by David Ask on 25/05/16.
//
//

public protocol Model: Table, RowConvertible {
    associatedtype PrimaryKey: Hashable, ValueConvertible
    static var primaryKeyField: Field { get }
    
    func serialize() -> [Field: ValueConvertible?]
    
    func willSave() throws
    func didSave()
    
    func willUpdate() throws
    func didUpdate()
    
    func willCreate() throws
    func didCreate()
    
    func willDelete() throws
    func didDelete()
    
    func willRefresh() throws
    func didRefresh()
}

public extension Model {
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

public extension Model where Field.RawValue == String {
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

public struct Entity<M: Model where M.Field.RawValue == String>: Equatable {
    
    public let primaryKey: M.PrimaryKey?
    public let model: M
    
    public init(model: M, primaryKey: M.PrimaryKey? = nil) {
        self.model = model
        self.primaryKey = primaryKey
    }
    
    public var persisted: Bool {
        return primaryKey != nil
    }
    
    public static func get<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(_ pk: M.PrimaryKey, connection: T) throws -> Entity? {
        
        var select = M.select(where: M.qualifiedPrimaryKeyField == pk)
        select.limit(to: 1)
        select.offset(by: 0)
        
        guard let row = try connection.execute(select).first else {
            return nil
        }
        
        return Entity(model: try M.init(row: row), primaryKey: try row.value(M.qualifiedPrimaryKeyField))
    }
    
    public static func fetchAll<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(connection: T) throws -> [Entity] {
        return try fetch(where: nil, limit: nil, offset: nil, connection: connection)
    }
    
    public static func first<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(where predicate: Predicate? = nil, connection: T) throws -> [Entity] {
        return try fetch(where: predicate, limit: 1, offset: 0, connection: connection)
    }
    
    public static func fetch<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(where predicate: Predicate? = nil, limit: Int? = 0, offset: Int? = 0, connection: T) throws -> [Entity] {
        var select = M.select
        
        if let predicate = predicate {
            select.filter(predicate)
        }
        
        if let limit = limit {
            select.limit(to: limit)
        }
        
        if let offset = offset {
            select.offset(by: offset)
        }
        
        return try connection.execute(select).map { Entity(model: try M.init(row: $0), primaryKey: try $0.value(M.qualifiedPrimaryKeyField)) }
    }
    
    public func delete<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(connection: T) throws -> Entity {
        guard let pk = primaryKey else {
            throw EntityError("Cannot delete a non-persisted model")
        }

        try connection.execute(M.delete(where: M.qualifiedPrimaryKeyField == pk))
        
        return Entity(model: model)
    }
    
    public func refresh<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(connection: T) throws -> Entity {
        guard let pk = primaryKey else {
            throw EntityError("Cannot refresh a non-persisted model")
        }
        
        try model.willRefresh()
        guard let refreshed = try self.dynamicType.get(pk, connection: connection) else {
            throw EntityError("Failed to re-fetch model with primary key \(pk)")
        }
        
        
        refreshed.model.didRefresh()
        return refreshed
    }
    
    public func create<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(connection: T) throws -> Entity {
        guard !persisted else {
            throw EntityError("Cannot insert an already persisted model")
        }
        
        return try connection.transaction {
            try self.model.willSave()
            try self.model.willCreate()

            let result = try connection.execute(M.insert(self.model.serialize()), returnInsertedRows: true)
            
            guard let row = result.first else {
                throw EntityError("Failed to retreieve row from insert result")
            }
            
            guard let pk: M.PrimaryKey = try row.value(M.qualifiedPrimaryKeyField) else {
                throw EntityError("Failed to retreieve primary key from insert")
            }
            
            var new = Entity(model: self.model, primaryKey: pk)
            
            new.model.didCreate()
            new.model.didSave()
            new = try new.refresh(connection: connection)
            return new
        }
    }
    
    public func update<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(connection: T) throws -> Entity {
        guard persisted else {
            throw EntityError("Cannot update a non-persisted model")
        }
        
        try model.willSave()
        try model.willUpdate()
        try connection.execute(M.update(model.serialize()))
        let new = try refresh(connection: connection)
        new.model.didUpdate()
        new.model.didSave()
        
        return new
    }
    
    public func save<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(connection: T) throws -> Entity {
        if persisted {
            return try update(connection: connection)
        }
        else {
            return try create(connection: connection)
        }
    }
}


public func == <M: Model>(lhs: Entity<M>, rhs: Entity<M>) -> Bool {
    guard let lpk = lhs.primaryKey, rpk = rhs.primaryKey else {
        return false
    }
    
    return "\(lhs.model.dynamicType.tableName).\(lpk.hashValue)" == "\(rhs.model.dynamicType.tableName).\(rpk.hashValue)"
}