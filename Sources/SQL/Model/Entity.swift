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

public protocol EntityProtocol {
    associatedtype Model: ModelProtocol

    var model: Model { get }
}

public protocol PersistedEntityProtocol: EntityProtocol, Equatable {
    var primaryKey: Model.PrimaryKey { get }
}

public extension EntityProtocol where Model.Field.RawValue == String {
    public static func get<Connection: ConnectionProtocol where Connection.Result.Iterator.Element: RowProtocol>(_ pk: Model.PrimaryKey, connection: Connection) throws -> PersistedEntity<Model>? {

        var select = Model.select(where: Model.Field.primaryKey == pk)
        select.limit(to: 1)
        select.offset(by: 0)

        guard let row = try connection.execute(select).first else {
            return nil
        }

        let tableRow = TableRow<Model, Connection.Result.Iterator.Element>(row: row)

        return PersistedEntity(model: try Model.init(row: tableRow), primaryKey: try tableRow.value(Model.Field.primaryKey))
    }

    public static func fetchAll<Connection: ConnectionProtocol where Connection.Result.Iterator.Element: RowProtocol>(connection: Connection) throws -> [PersistedEntity<Model>] {
        return try fetch(where: nil, limit: nil, offset: nil, connection: connection)
    }

    public static func first<Connection: ConnectionProtocol where Connection.Result.Iterator.Element: RowProtocol>(where predicate: Predicate? = nil, connection: Connection) throws -> PersistedEntity<Model>? {
        return try fetch(where: predicate, limit: 1, offset: 0, connection: connection).first
    }

    public static func fetch<Connection: ConnectionProtocol where Connection.Result.Iterator.Element: RowProtocol>(where predicate: Predicate? = nil, limit: Int? = 0, offset: Int? = 0, connection: Connection) throws -> [PersistedEntity<Model>] {
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

            let tableRow = TableRow<Model, Connection.Result.Iterator.Element>(row: row)

            return PersistedEntity(model: try Model.init(row: tableRow), primaryKey: try tableRow.value(Model.Field.primaryKey))
        }
    }

    public func create<Connection: ConnectionProtocol where Connection.Result.Iterator.Element: RowProtocol>(connection: Connection) throws -> PersistedEntity<Model> {
        return try connection.transaction {
            try self.model.willSave()
            try self.model.willCreate()

            let result = try connection.execute(Model.insert(self.model.serialize()), returnInsertedRows: true)

            guard let row = result.first else {
                throw EntityError("Failed to retreieve row from insert result")
            }

            guard let pk: Model.PrimaryKey = try row.value(Model.Field.primaryKey.qualifiedField) else {
                throw EntityError("Failed to retreieve primary key from insert")
            }

            var new = PersistedEntity(model: self.model, primaryKey: pk)

            new.model.didCreate()
            new.model.didSave()

            new = try new.refresh(connection: connection)

            return new
        }
    }

    public func save<Connection: ConnectionProtocol where Connection.Result.Iterator.Element: RowProtocol>(connection: Connection) throws -> PersistedEntity<Model> {
        return try create(connection: connection)
    }
}

public extension PersistedEntityProtocol where Model.Field.RawValue == String {
    public func delete<Connection: ConnectionProtocol where Connection.Result.Iterator.Element: RowProtocol>(connection: Connection) throws -> Entity<Model> {
        try connection.execute(Model.delete(where: Model.Field.primaryKey == self.primaryKey))

        return Entity(model: model)
    }

    public func refresh<Connection: ConnectionProtocol where Connection.Result.Iterator.Element: RowProtocol>(connection: Connection) throws -> PersistedEntity<Model> {
        try model.willRefresh()

        guard let refreshed = try self.dynamicType.get(primaryKey, connection: connection) else {
            throw EntityError("Failed to re-fetch model with primary key \(primaryKey)")
        }

        refreshed.model.didRefresh()

        return refreshed
    }

    public func update<Connection: ConnectionProtocol where Connection.Result.Iterator.Element: RowProtocol>(connection: Connection) throws -> PersistedEntity<Model> {
        try model.willSave()
        try model.willUpdate()

        try connection.execute(Model.update(model.serialize()))

        let new = try refresh(connection: connection)
        new.model.didUpdate()
        new.model.didSave()

        return new
    }

    public func save<Connection: ConnectionProtocol where Connection.Result.Iterator.Element: RowProtocol>(connection: Connection) throws -> PersistedEntity<Model> {
        return try update(connection: connection)
    }
}

public struct Entity<Model: ModelProtocol where Model.Field.RawValue == String>: EntityProtocol {
    public let model: Model

    public init(model: Model) {
        self.model = model
    }
}

public struct PersistedEntity<Model: ModelProtocol where Model.Field.RawValue == String>: PersistedEntityProtocol {
    public let model: Model
    public let primaryKey: Model.PrimaryKey

    public init(model: Model, primaryKey: Model.PrimaryKey) {
        self.model = model
        self.primaryKey = primaryKey
    }
}

public func == <Model: ModelProtocol, Entity: PersistedEntityProtocol where Entity.Model == Model>(lhs: Entity, rhs: Entity) -> Bool {
    return "\(Model.Field.tableName).\(lhs.primaryKey.hashValue)" == "\(Model.Field.tableName).\(rhs.primaryKey.hashValue)"
}
