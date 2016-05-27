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

public protocol Model: class, Table {
    associatedtype PrimaryKey: ValueConvertible
    
    var primaryKey: PrimaryKey? { get set }
    
    static var primaryKeyField: Field { get }
    
    var persistedValuesByField: [Field: ValueConvertible?] { get }
    
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

public extension Model where Self.Field.RawValue == String {
    
    static var qualifiedPrimaryKeyField: QualifiedField {
        return field(primaryKeyField)
    }
    
    func insert<T: ConnectionProtocol>(in connection: T) throws {
        guard !persisted else {
            throw ModelError("Cannot insert an already persisted model")
        }
        
        willSave()
        willCreate()
        let result = try connection.execute(Self.insert(persistedValuesByField).returning(Self.qualifiedPrimaryKeyField))
        primaryKey = try result.first?.value(Self.qualifiedPrimaryKeyField)
        didCreate()
        didSave()
    }
    
    func update<T: ConnectionProtocol>(in connection: T) throws {
        guard persisted else {
            throw ModelError("Cannot update a non-persisted model")
        }
        
        willSave()
        willUpdate()
        try connection.execute(Self.update(persistedValuesByField))
        didUpdate()
        didSave()
    }
    
    func save<T: ConnectionProtocol>(in connection: T) throws {
        if persisted {
            try update(in: connection)
        }
        else {
            try insert(in: connection)
        }
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
