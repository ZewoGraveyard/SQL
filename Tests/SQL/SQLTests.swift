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
        
        
        
        let subquery = Select(User.field(.id), from: "users")

        let firstQuery = Select(subquery.subqueryNamed("u"), User.field(.id), from: User.tableName).filter("id" == 2).first
        
        User.select(.id).extend(Order.field(.id))
        
    }
}

