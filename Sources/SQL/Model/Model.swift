//// Model.swift
////
//// The MIT License (MIT)
////
//// Copyright (c) 2015 Formbound
////
//// Permission is hereby granted, free of charge, to any person obtaining a copy
//// of this software and associated documentation files (the "Software"), to deal
//// in the Software without restriction, including without limitation the rights
//// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//// copies of the Software, and to permit persons to whom the Software is
//// furnished to do so, subject to the following conditions:
////
//// The above copyright notice and this permission notice shall be included in all
//// copies or substantial portions of the Software.
////
//// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//// SOFTWARE.
//
//
//
//
//public struct ModelError: ErrorProtocol {
//    public let description: String
//
//    public init(description: String) {
//        self.description = description
//    }
//}
//
//public enum ModelChangeStatus {
//    case Unknown
//    case Changed
//    case Unchanged
//}
//
//public protocol Model: Table {
//    associatedtype PrimaryKeyType:SQLDataConvertible
//
//    var primaryKey: PrimaryKeyType? { get }
//
//    static var selectFields: [Field] { get }
//
//
//
//
//
//    var changedFields: [Field]? { get set }
//
//    var persistedValuesByField: [Field: SQLDataConvertible?] { get }
//
//    mutating func create<T: Connection where T.ResultType.Iterator.Element == Row>(connection: T) throws
//
//    static func create<T: SQL.Connection where T.ResultType.Iterator.Element == Row>(values: [Field: SQLDataConvertible?], connection: T) throws -> Self
//
//    func willSave()
//    func didSave()
//
//    func willUpdate()
//    func didUpdate()
//
//    func willCreate()
//    func didCreate()
//
//    func willDelete()
//    func didDelete()
//
//    func willRefresh()
//    func didRefresh()
//
//    func validate() throws
//
//    init(row: Row) throws
//}
//
//public extension Model {
//
//    public static var selectFields: [Field] {
//        return []
//    }
//
//    public static var selectQuery: ModelSelect<Self> {
//        return ModelSelect()
//    }
//
//    public static func updateQuery(values: [Field: SQLDataConvertible?] = [:]) -> ModelUpdate<Self> {
//        return ModelUpdate(values)
//    }
//
//    public static var deleteQuery: ModelDelete<Self> {
//        return ModelDelete()
//    }
//
//    public static func insertQuery(values: [Field: SQLDataConvertible?]) -> ModelInsert<Self> {
//        return ModelInsert(values)
//    }
//
//    public mutating func setNeedsSave(field: Field) throws {
//        guard var changedFields = changedFields else {
//            throw ModelError(description: "Cannot set changed value, as property `changedFields` is nil")
//        }
//
//        guard !changedFields.contains(field) else {
//            return
//        }
//
//        changedFields.append(field)
//        self.changedFields = changedFields
//    }
//
//    public var changedFields: [Self.Field]? {
//        get { return nil }
//        set { return }
//    }
//
//    public var hasChanged: ModelChangeStatus {
//        guard let changedFields = changedFields else {
//            return .Unknown
//        }
//
//        return changedFields.isEmpty ? .Unchanged : .Changed
//    }
//
//    public var changedValuesByField: [Field: SQLDataConvertible?]? {
//        guard let changedFields = changedFields else {
//            return nil
//        }
//
//        var dict = [Field: SQLDataConvertible?]()
//
//        var values = persistedValuesByField
//
//        for field in changedFields {
//            dict[field] = values[field]
//        }
//
//        return dict
//    }
//
//    public var persistedFields: [Field] {
//        return Array(persistedValuesByField.keys)
//    }
//
//
//    public var isPersisted: Bool {
//        return primaryKey != nil
//    }
//
//    public static var declaredSelectFields: [DeclaredField] {
//        return selectFields.map { Self.field($0) }
//    }
//
//    public static func get<T: Connection where T.ResultType.Iterator.Element == Row>(pk: Self.PrimaryKeyType, connection: T) throws -> Self? {
//        return try selectQuery.filter(declaredPrimaryKeyField == pk).first(connection)
//    }
//
//    public mutating func refresh<T: Connection where T.ResultType.Iterator.Element == Row>(connection: T) throws {
//        guard let pk = primaryKey, newSelf = try Self.get(pk, connection: connection) else {
//            throw ModelError(description: "Cannot refresh a non-persisted model. Please use insert() or save() first.")
//        }
//
//        willRefresh()
//        self = newSelf
//        didRefresh()
//    }
//
//    public mutating func update<T: Connection where T.ResultType.Iterator.Element == Row>(connection: T) throws {
//        guard let pk = primaryKey else {
//            throw ModelError(description: "Cannot update a model that isn't persisted. Please use insert() first or save()")
//        }
//
//        let values = changedValuesByField ?? persistedValuesByField
//
//        guard !values.isEmpty else {
//            throw ModelError(description: "Nothing to save")
//        }
//
//        try validate()
//
//        willSave()
//        willUpdate()
//        try Self.updateQuery(values).filter(Self.declaredPrimaryKeyField == pk).execute(connection)
//        didUpdate()
//        try self.refresh(connection)
//        didSave()
//    }
//
//    public mutating func delete<T: Connection where T.ResultType.Iterator.Element == Row>(connection: T) throws {
//        guard let pk = self.primaryKey else {
//            throw ModelError(description: "Cannot delete a model that isn't persisted.")
//        }
//
//        willDelete()
//        try Self.deleteQuery.filter(Self.declaredPrimaryKeyField == pk).execute(connection)
//        didDelete()
//    }
//
//    public mutating func save<T: Connection where T.ResultType.Iterator.Element == Row>(connection: T) throws {
//
//        if isPersisted {
//            try update(connection)
//        }
//        else {
//            try create(connection)
//            guard isPersisted else {
//                fatalError("Primary key not set after insert. This is a serious error in an SQL adapter. Please consult a developer.")
//            }
//        }
//    }
//}
//
//public extension Model {
//    public func willSave() {}
//    public func didSave() {}
//
//    public func willUpdate() {}
//    public func didUpdate() {}
//
//    public func willCreate() {}
//    public func didCreate() {}
//
//    public func willDelete() {}
//    public func didDelete() {}
//
//    public func willRefresh() {}
//    public func didRefresh() {}
//
//    public func validate() throws {}
//}