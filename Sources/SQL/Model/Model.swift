//
//  Model.swift
//  SQL
//
//  Created by David Ask on 25/05/16.
//
//

public struct ModelError: ErrorProtocol {
    public let description: String
    
    public init(_ description: String) {
        self.description = description
    }
}

public protocol Model: Table, Equatable {
    associatedtype PrimaryKey: ValueConvertible, Hashable
    
    var primaryKey: PrimaryKey? { get set }
    
    static var primaryKeyField: Field { get }
    
    var serialize: [Field: ValueConvertible?] { get }
    
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

public func == <L: Model, R: Model>(lhs: L, rhs: R) -> Bool {
    guard let lpk = lhs.primaryKey, rpk = rhs.primaryKey else {
        return false
    }
    
    return "\(L.tableName).\(lpk.hashValue)" == "\(R.tableName).\(rpk.hashValue)"
}

public extension Model where Self.Field.RawValue == String {
    
    static var qualifiedPrimaryKeyField: QualifiedField {
        return field(primaryKeyField)
    }
    
    mutating func create<T: ConnectionProtocol where T.Result.Iterator.Element == Row>(connection: T) throws -> Self {
        guard !persisted else {
            throw ModelError("Cannot insert an already persisted model")
        }
        
        try connection.transaction {
            self.willSave()
            self.willCreate()
            let result = try connection.execute(Self.insert(self.serialize).returning(Self.qualifiedPrimaryKeyField))
            
            guard let pk: PrimaryKey = try result.first?.value(Self.qualifiedPrimaryKeyField) else {
                throw ModelError("Failed to retreieve primary key from insert statement")
            }
            
            self.primaryKey = pk
            
            self.didCreate()
            self.didSave()
            try self.refresh(connection: connection)
            
        }

        return self
    }
    
    mutating func refresh<T: ConnectionProtocol where T.Result.Iterator.Element == Row>(connection: T) throws -> Self {
        guard let pk = primaryKey else {
            throw ModelError("Cannot refresh a non-persisted model")
        }
        
        willRefresh()
        guard let refreshed = try Self.get(pk, connection: connection) else {
            throw ModelError("Failed to re-fetch model with primary key \(pk)")
        }
        
        self = refreshed
        didRefresh()
        return self
    }
    
    mutating func update<T: ConnectionProtocol where T.Result.Iterator.Element == Row>(connection: T) throws -> Self {
        guard persisted else {
            throw ModelError("Cannot update a non-persisted model")
        }
        
        willSave()
        willUpdate()
        try connection.execute(Self.update(serialize))
        try refresh(connection: connection)
        didUpdate()
        didSave()
        return self
    }
    
    mutating func save<T: ConnectionProtocol where T.Result.Iterator.Element == Row>(connection: T) throws -> Self {
        if persisted {
            return try update(connection: connection)
        }
        else {
            return try create(connection: connection)
        }
    }
    
    mutating func delete<T: ConnectionProtocol>(connection: T) throws {
        guard let pk = primaryKey else {
            throw ModelError("Cannot delete a non-persisted model")
        }
        
        try connection.execute(Self.delete(where: Self.qualifiedPrimaryKeyField == pk))
        primaryKey = nil
    }
    
    public static func get<T: ConnectionProtocol where T.Result.Iterator.Element == Row>(_ pk: PrimaryKey, connection: T) throws -> Self? {
        guard let row = try connection.execute(select().filter(qualifiedPrimaryKeyField == pk).first).first else {
            return nil
        }
        
        return try Self.init(row: row)
    }
    
    public static func fetch<T: ConnectionProtocol where T.Result.Iterator.Element == Row>(where predicate: Predicate? = nil, limit: Int? = 0, offset: Int? = 0, connection: T) throws -> [Self] {
        let select = Self.select()
        
        if let predicate = predicate {
            select.filter(predicate)
        }
        
        if let limit = limit {
            select.limit(limit)
        }
        
        if let offset = offset {
            select.offset(offset)
        }
        
        return try connection.execute(select).map { try Self(row: $0) }
    }
}

public extension Model {
    
    public var persisted: Bool {
        return primaryKey != nil
    }
    
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
