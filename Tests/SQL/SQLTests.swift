import XCTest
@testable import SQL


class SQLTests: XCTestCase {
    func testSelectQuey() {
        
        
        
        let subquery = Select(User.field(.id), from: "users")

        let firstQuery = Select(subquery.subqueryNamed("u"), User.field(.id), from: User.tableName).filter("id" == 2).first
        
        User.select(.id).extend(Order.field(.id))
        
    }
}

