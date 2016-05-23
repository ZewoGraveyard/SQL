import XCTest
@testable import SQL

extension Table {
    public static func f(_ field: Field) -> DeclaredField {
        return self.field(field)
    }
}


struct Artist {
    let id: Int?
    var name: String
    var genre: Int
    
}


extension Artist: Table {
    enum Field: String, FieldType {
        case id = "id"
        case name = "name"
        case genreId = "genre_id"
        case sex
//        case salary1, salary2, salary3
    }
    
    // Table name corresponding to your model
    static let tableName: String = "artists"
    
    // The field for the primary key of the model
    static let fieldForPrimaryKey: Field = .id
    
    
}

struct Genre: Table {
    
    enum Field: String, FieldType {
        case id = "id", name
    }
    
    static let tableName: String = "genres"
    static let fieldForPrimaryKey: Field = .id
}





//case
//let cases = Case([
//        (Event.f(.id)>5 && Event.f(.name) < "asd", "asd"),
//        (Event.f(.id)<5, "3123")
//], _else: "32").alias("username")


//case as select field
//let q = Select(cases, "asdA", Event.f(.id).alias("event_id"), from: "nil")












//let q = Select(Event.f(.id)+"  "+Event.f(.name), from: Event.self)




//let d2 = "asdsa"

//extension QueryComponentRepresentable:StringLiteralConvertible {
//
//}

//let q = Select(Event.f(.id), from: "asdasd").filter(field("asdas") == "fdsdasf" && "f" == d2.sqlData )

//print(q.queryComponent)


//let q2 = Insert([Event.f(.id): subq, "naame": subq], into: "asd")


//let q = Update("table", set: ["name": subq]).filter("asd"==Func.count(d2, "secondarg") && "asd" == "fds2")

//print(Compiler().compile(q))
//print(Compiler().compile(q2))













//print(q.queryComponent.string)






//todo:
//relations
//select subquery -done
//count
//func
//case -done
//columns types, binding, numberfromlalal
//column_property !!
//bundles
//group by -done
//aliasing query -done

//join query --dpone

let compiler = Compiler()

func compile(_ query: QueryComponentRepresentable) -> String {
    return compiler.compile(query).statement
}


class SQLTests: XCTestCase {
//    init() {
    
//    }
    func testSelect() {
//         Pass table name as type, field as .field
        let q = Select(.name, .genreId, from: Artist.self)
        let sql = "SELECT artists.name , artists.genre_id FROM artists"
        XCTAssertEqual(compile(q), sql)
    }
    func testFilter() {
        
    }
    
    func testFieldAlias() {
        let q = Select(Artist.f(.name).alias("artist_name"), from: Artist.tableName)
        let sql = "SELECT artists.name as artist_name FROM artists"
        XCTAssertEqual(compile(q), sql)
    }
    func testChainingSelect() {
        let q = Select(.name, from: Artist.self).select("field", "otherfield")
        let sql = "SELECT artists.name , field , otherfield FROM artists"
        XCTAssertEqual(compile(q), sql)

    }
    func testSelectGroupBy() {
        let q = Select(from: Artist.self).groupBy(Artist.f(.genreId), Artist.f(.sex))
        let sql = "SELECT * FROM artists GROUP BY artists.genre_id , artists.sex"
        XCTAssertEqual(compile(q), sql)
    }
    
    
    func testSelectSubquery() {
        let genre = Select(Genre.f(.name), from: Genre.tableName).filter(Genre.f(.id)==1).asSubquery("genre_name")
        let q = Select(genre, from: Genre.tableName)
        let sql = "SELECT ( SELECT genres.name FROM genres WHERE genres.id = %s ) AS genre_name FROM genres"
        XCTAssertEqual(compile(q), sql)
    }
    
    func testSelectOrder() {
//        let q = Select(event, from: Artist)
    }
    
//    .orderBy(.Ascending("asd")).limit(1000).offset(12)
    
    func testSelectJoin() {
        
    }
    
    func testSelectJoinSubquery() {
        let genres = Select(from: Genre.self).asSubquery("subq")
        let q = Select(from: Artist.self).join(genres, using: [.Inner], leftKey: Artist.f(.genreId), rightKey: genres.field("id"))
        let sql = "SELECT * FROM artists INNER JOIN ( SELECT * FROM genres ) AS subq ON artists.genre_id = subq.id"
        XCTAssertEqual(compile(q), sql)

    }
    
    
    func testInsert() {
        let q = Insert([.id: 12, .genreId: 12], into: Artist.self)
        let sql = "INSERT INTO artists ( id , genre_id ) VALUES ( %s , %s ) RETURNING artists.id as id"
        XCTAssertEqual(compile(q), sql)
    }
    func testInsert2() {
        let q = Insert([Artist.f(.id): 12, Artist.f(.genreId): 12], into: Artist.tableName)
        let sql = "INSERT INTO artists ( id , genre_id ) VALUES ( %s , %s ) RETURNING artists.id as id"
        XCTAssertEqual(compile(q), sql)
    }
    
    func testInsertSubquery() {
        let genreId = Select(.id, from: Genre.self).asSubquery()
        let q = Insert([.id: 12, .genreId: genreId], into: Artist.self)
        let sql = "INSERT INTO artists ( id , genre_id ) VALUES ( %s , ( SELECT genres.id FROM genres ) ) RETURNING artists.id as id"
        XCTAssertEqual(compile(q), sql)
        
    }
    
    func testDelete() {
        let q = Delete(from: "table")
        let sql = "DELETE FROM table"
        XCTAssertEqual(compile(q), sql)
    }
    func testDeleteFilter() {
        let q = Delete(from: Artist.tableName).filter(Artist.f(.name) == "Taylor Swift")
        let sql = "DELETE FROM artists WHERE artists.name = %s"
        XCTAssertEqual(compile(q), sql)
    }
}

extension SQLTests {
    static var allTests: [(String, SQLTests -> () throws -> Void)] {
        return [
//           ("testReality", testReality),
        ]
    }
}