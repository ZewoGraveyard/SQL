//
// Created by badim on 3/21/16.
//





public protocol Table {
    associatedtype Field:FieldType

    static var fieldForPrimaryKey: Field { get }

    static var tableName: String { get }
}

extension Table {
    public static func field(field: Field) -> DeclaredField {
        return DeclaredField(name: field.rawValue, tableName: Self.tableName)
    }

    public static func field(field: String) -> DeclaredField {
        return DeclaredField(name: field, tableName: Self.tableName)
    }

    public static var declaredPrimaryKeyField: DeclaredField {
        return field(fieldForPrimaryKey)
    }
}




//
//public struct Relation<LeftTable: Table, RightTable: Table> {
//    let leftField: DeclaredField
//    let rightField: DeclaredField
//    public init(_ leftField: LeftTable.Field, _ rightField: RightTable.Field) {
//        self.leftField = LeftTable.field(leftField)
//        self.rightField = RightTable.field(rightField)
//    }
//}
