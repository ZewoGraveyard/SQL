import XCTest
@testable import SQL

struct User: Table {
    enum Field: String {
        case id = "id"
        case username = "username"
    }
    
    static var tableName: String = "users"
}

struct Order: Table {
    enum Field: String {
        case id = "id"
        case userId = "user_id"
    }
    
    static var tableName: String = "orders"
}

class SQLTests: XCTestCase {
    func testSelectQuey() {
        
        
        print(User.select(.id, .username).limit(10).offset(10).order(.asc(User.field(.id))))
        print(
            User.select(top: .percent(10), .id, .username)
            .join(.inner(Order.tableName), on: Order.field(.id), equals: User.field(.id))
            .limit(10)
            .offset(10)
            )
        
        
        
        print(Select("id", Select("count(*)", from: "orders"), from: "id").filter("id" == 2))

        
    }
}

