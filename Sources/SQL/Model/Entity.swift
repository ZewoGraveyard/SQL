// Entity.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2016 Formbound
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

public struct Entity<Model: ModelProtocol where Model.Field.RawValue == String>: Equatable {
    
    public let primaryKey: Model.PrimaryKey?
    public let model: Model
    
    public init(model: Model, primaryKey: Model.PrimaryKey? = nil) {
        self.model = model
        self.primaryKey = primaryKey
    }
    
    public var persisted: Bool {
        return primaryKey != nil
    }
    
    public static func get<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(_ pk: Model.PrimaryKey, connection: T) throws -> Entity? {
        
        var select = Model.select(where: Model.qualifiedPrimaryKeyField == pk)
        select.limit(to: 1)
        select.offset(by: 0)
        
        guard let row = try connection.execute(select).first else {
            return nil
        }
        
        let tableRow = TableRow<Model, T.Result.Iterator.Element>(row: row)
        
        return Entity(model: try Model.init(row: tableRow), primaryKey: try tableRow.value(Model.primaryKeyField))
    }
    
    public static func fetchAll<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(connection: T) throws -> [Entity] {
        return try fetch(where: nil, limit: nil, offset: nil, connection: connection)
    }
    
    public static func first<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(where predicate: Predicate? = nil, connection: T) throws -> [Entity] {
        return try fetch(where: predicate, limit: 1, offset: 0, connection: connection)
    }
    
    public static func fetch<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(where predicate: Predicate? = nil, limit: Int? = 0, offset: Int? = 0, connection: T) throws -> [Entity] {
        var select = Model.select
        
        if let predicate = predicate {
            select.filter(predicate)
        }
        
        if let limit = limit {
            select.limit(to: limit)
        }
        
        if let offset = offset {
            select.offset(by: offset)
        }
        
        return try connection.execute(select).map {
            row in
            
            let tableRow = TableRow<Model, T.Result.Iterator.Element>(row: row)
            
            return Entity(model: try Model.init(row: tableRow), primaryKey: try tableRow.value(Model.primaryKeyField))
        }
    }
    
    public func delete<T: ConnectionProtocol where T.Result.Iterator.Element: RowProtocol>(connection: T) throws -> Entity {
        guard let pk = primaryKey else {
            throw EntityError("Cannot delete a non-persisted model")
        }
        
        try connection.execute(Model.delete(where: Model.qualifiedPrimaryKeyField == pk))
        
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
            
            let result = try connection.execute(Model.insert(self.model.serialize()), returnInsertedRows: true)
            
            guard let row = result.first else {
                throw EntityError("Failed to retreieve row from insert result")
            }
            
            guard let pk: Model.PrimaryKey = try row.value(Model.qualifiedPrimaryKeyField) else {
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
        try connection.execute(Model.update(model.serialize()))
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


public func == <Model: ModelProtocol>(lhs: Entity<Model>, rhs: Entity<Model>) -> Bool {
    guard let lpk = lhs.primaryKey, rpk = rhs.primaryKey else {
        return false
    }
    
    return "\(lhs.model.dynamicType.tableName).\(lpk.hashValue)" == "\(rhs.model.dynamicType.tableName).\(rpk.hashValue)"
}
