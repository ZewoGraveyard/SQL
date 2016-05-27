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

public protocol Model: class, Table, Equatable {
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
    
    func create<T: ConnectionProtocol>(in connection: T) throws -> Self {
        guard !persisted else {
            throw ModelError("Cannot insert an already persisted model")
        }
        
        willSave()
        willCreate()
        let result = try connection.execute(Self.insert(serialize).returning(Self.qualifiedPrimaryKeyField))
        primaryKey = try result.first?.value(Self.qualifiedPrimaryKeyField)
        didCreate()
        didSave()
        return self
    }
    
    func update<T: ConnectionProtocol>(in connection: T) throws -> Self {
        guard persisted else {
            throw ModelError("Cannot update a non-persisted model")
        }
        
        willSave()
        willUpdate()
        try connection.execute(Self.update(serialize))
        didUpdate()
        didSave()
        return self
    }
    
    func save<T: ConnectionProtocol>(in connection: T) throws -> Self {
        if persisted {
            try update(in: connection)
        }
        else {
            try create(in: connection)
        }
        return self
    }
    
    func delete<T: ConnectionProtocol>(in connection: T) throws {
        guard let primaryKey = primaryKey else {
            throw ModelError("Cannot delete a non-persisted model")
        }
        
        try connection.execute(Self.delete(where: Self.qualifiedPrimaryKeyField == primaryKey))
    }
    
    public static func get<T: ConnectionProtocol where T.Result.Iterator.Element == Row>(_ pk: PrimaryKey, in connection: T) throws -> Self? {
        guard let row = try connection.execute(select().filter(qualifiedPrimaryKeyField == pk).first).first else {
            return nil
        }
        
        return try Self.init(row: row)
    }
    
    public static func fetch<T: ConnectionProtocol where T.Result.Iterator.Element == Row>(where predicate: Predicate, limit: Int? = 0, offset: Int? = 0, in connection: T) throws -> [Self] {
        let select = Self.select().filter(predicate)
        
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
