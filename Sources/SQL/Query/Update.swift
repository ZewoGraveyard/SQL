//// Update.swift
////
//// The MIT License (MIT)
////
//// Copyright (c) 2016 Formbound
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
public struct Update: UpdateQuery {
    public let tableName: String

    public var valuesByField: [DeclaredField: SQLData?]

    public var condition: Condition?

    public init(_ tableName: String, set valuesByField: [DeclaredField : SQLData?] = [:]) {
        self.tableName = tableName
        self.valuesByField = valuesByField
    }

    public init(_ tableName: String, set valuesByField: [DeclaredField : SQLDataRepresentable?] = [:]) {

        var dict = [DeclaredField: SQLData?]()

        for (key, value) in valuesByField {
            dict[key] = value?.sqlData
        }

        self.init(tableName, set: dict)
    }
}

//public struct ModelUpdate<T: Model>: UpdateQuery {
//    public typealias ModelType = T
//
//    public var tableName: String {
//        return T.tableName
//    }
//
//    public var valuesByField: [DeclaredField: SQLData?] = [:]
//
//    public var condition: Condition?
//
//    public init(_ values: [ModelType.Field: SQLData?]) {
//        var dict = [DeclaredField: SQLData?]()
//
//        for (key, value) in values {
//            dict[ModelType.field(key)] = value
//        }
//
//        self.valuesByField = dict
//    }
//
//    public init(_ values: [ModelType.Field: SQLDataConvertible?]) {
//        var dict = [DeclaredField: SQLData?]()
//
//        for (key, value) in values {
//            dict[ModelType.field(key)] = value?.sqlData
//        }
//
//        self.valuesByField = dict
//    }
//
//    public mutating func set(value: SQLData?, forField field: ModelType.Field) {
//        set(value, forField: ModelType.field(field))
//    }
//
//    public mutating func set(value: SQLDataConvertible?, forField field: ModelType.Field) {
//        set(value?.sqlData, forField: field)
//    }
//}
//
public protocol UpdateQuery: FilteredQuery, TableQuery {
    var valuesByField: [DeclaredField: SQLData?] { get set }
}
//
public extension UpdateQuery {

    public mutating func set(_ value: SQLData?, forField field: DeclaredField) {
        valuesByField[field] = value
    }

    public mutating func set(_ value: SQLDataConvertible?, forField field: DeclaredField) {
        self.set(value?.sqlData, forField: field)
    }

    public var queryComponent: QueryComponent {
        return .update(table: .table(name: tableName, alias: nil), set: valuesByField, filter: condition?.queryComponent)
    }
}