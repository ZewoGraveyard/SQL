//// Insert.swift
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
public typealias ValuesList = OrderedDict<DeclaredField, SQLDataRepresentable>

//
//
//public struct Insert: InsertQuery {
//    public let source: Source
//    public let valuesByField: ValuesList
//    public var returning: [DeclaredField]
//
//
//    public init<T: Table>(_ valuesByField: OrderedDict<T.Field, SQLDataRepresentable>, into table: T.Type) {
//        let newValues = valuesByField.elements.map {(T.field($0.0), $0.1)}
//        let values = OrderedDict(elements: newValues)
//        self.init(values, into: table.tableName)
//    }
//    
//    public init(_ valuesByField: ValuesList, into tableName: String) {
//        self.source = tableName.source
//        self.valuesByField = valuesByField
//        self.returning = [DeclaredField(name: "id", tableName: tableName, alias: "id")]
//    }
//
//}
//
//public struct ModelInsert<T: Model>: InsertQuery {
//    public typealias ModelType = T
//
//    public var tableName: String {
//        return ModelType.tableName
//    }
//
//    public let valuesByField: [DeclaredField: SQLData?]
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
//}
//

//public protocol InsertQuery : TableQuery {
//    var valuesByField: ValuesList { get }
//    var returning: [DeclaredField] { get }
//}


//extension InsertQuery {
//    public var queryComponent: QueryComponent {
//        return .insert(into: .table(name: tableName, alias: nil), values: valuesByField,
//                returning: returning.map{ $0.queryComponent })
//    }
//}