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
    var sex: Int
}


extension Artist: Table {
    enum Field: String, FieldType {
        case id = "id"
        case name = "name"
        case genreId = "genre_id"
        case sex
    }
    static let tableName: String = "artists"
    static let fieldForPrimaryKey: Field = .id
    
    
}

struct Genre: Table {
    
    enum Field: String, FieldType {
        case id = "id", name
    }
    
    static let tableName: String = "genres"
    static let fieldForPrimaryKey: Field = .id
}






//let q = Select(Event.f(.id)+"  "+Event.f(.name), from: Event.self)

//let d2 = "asdsa"


//let q = Select(Event.f(.id), from: "asdasd").filter(field("asdas") == "fdsdasf" && "f" == d2.sqlData )







//todo:
//relations

//count
//func
//case -done
//columns types, binding, numberfromlalal
//column_property !!
//bundles

let compiler = Compiler()

//func compile<T>(_ query: T) -> String {
//    return compiler.compile(query).statement
//}


class SelectTests: XCTestCase {
    func testSelectGeneric() {
        let q = Select(.name, .genreId, from: Artist.self)
        let sql = "SELECT artists.name, artists.genre_id FROM artists"
        XCTAssertEqual(compiler.compile(q), sql)
    }
    func testFilter() {
        
    }
    
    func testFieldAlias() {
        let q = Select(Artist.f(.name).alias("artist_name"), from: Artist.tableName)
        let sql = "SELECT artists.name as artist_name FROM artists"
        XCTAssertEqual(compiler.compile(q), sql)
    }
    func testChainingSelect() {
        let q = Select(.name, from: Artist.self).select(field("field"), field("otherfield"))
        let sql = "SELECT artists.name , field , otherfield FROM artists"
        XCTAssertEqual(compiler.compile(q), sql)

    }
    func testSelectGroupBy() {
        let q = Select(from: Artist.self).groupBy(Artist.f(.genreId), Artist.f(.sex))
        let sql = "SELECT * FROM artists GROUP BY artists.genre_id , artists.sex"
        XCTAssertEqual(compiler.compile(q), sql)
    }
    
    
    func testSelectSubquery() {
        let genre = Select(Genre.f(.name), from: Genre.tableName).filter(Genre.f(.id)==1).asSubquery("genre_name")
        let q = Select(genre, from: Genre.tableName)
        let sql = "SELECT ( SELECT genres.name FROM genres WHERE genres.id = %s ) AS genre_name FROM genres"
        XCTAssertEqual(compiler.compile(q), sql)
    }
    
    func testSelectOrder() {
        let q = Select(from: Artist.self).orderBy(.Ascending(Artist.f(.id)), .Descending(Artist.f(.name)))
        let sql = "SELECT * FROM artists ORDER BY artists.id ASC , artists.name DESC"
        XCTAssertEqual(compiler.compile(q), sql)
    }
    
    func testSelectLimit() {
        let q = Select(from: Artist.self).limit(42)
        let sql = "SELECT * FROM artists LIMIT 42"
        XCTAssertEqual(compiler.compile(q), sql)
    }
    func testSelectOffset() {
        let q = Select(from: Artist.self).offset(13)
        let sql = "SELECT * FROM artists OFFSET 13"
        XCTAssertEqual(compiler.compile(q), sql)
    }
    func testSelectOffsetLimit() {
        let q = Select(from: Artist.self).offset(13).limit(42)
        let sql = "SELECT * FROM artists LIMIT 42 OFFSET 13"
        XCTAssertEqual(compiler.compile(q), sql)
    }
    
    func testSelectJoin() {
        
    }
    
//    func testSelectJoinSubquery() {
//        let genres = Select(from: Genre.self).asSubquery("subq")
//        let q = Select(from: Artist.self).join(genres, using: [.Inner], leftKey: Artist.f(.genreId), rightKey: genres.field("id"))
//        let sql = "SELECT * FROM artists INNER JOIN ( SELECT * FROM genres ) AS subq ON artists.genre_id = subq.id"
//        XCTAssertEqual(compile(q), sql)
//
//    }
}
//class InsertTests: XCTestCase {
//    func testInsert() {
//        let q = Insert([.id: 12, .genreId: 12], into: Artist.self)
//        let sql = "INSERT INTO artists ( id , genre_id ) VALUES ( %s , %s ) RETURNING artists.id as id"
//        XCTAssertEqual(compile(q), sql)
//    }
//    func testInsert2() {
//        let q = Insert([Artist.f(.id): 12, Artist.f(.genreId): 12], into: Artist.tableName)
//        let sql = "INSERT INTO artists ( id , genre_id ) VALUES ( %s , %s ) RETURNING artists.id as id"
//        XCTAssertEqual(compile(q), sql)
//    }
//    
//    func testInsertSubquery() {
//        let genreId = Select(.id, from: Genre.self).asSubquery()
//        let q = Insert([.id: 12, .genreId: genreId], into: Artist.self)
//        let sql = "INSERT INTO artists ( id , genre_id ) VALUES ( %s , ( SELECT genres.id FROM genres ) ) RETURNING artists.id as id"
//        XCTAssertEqual(compile(q), sql)
//        
//    }
//}
//class DeleteTests: XCTestCase {
//    func testDelete() {
//        let q = Delete(from: "table")
//        let sql = "DELETE FROM table"
//        XCTAssertEqual(compile(q), sql)
//    }
//    func testDeleteFilter() {
//        let q = Delete(from: Artist.tableName).filter(Artist.f(.name) == "Taylor Swift")
//        let sql = "DELETE FROM artists WHERE artists.name = %s"
//        XCTAssertEqual(compile(q), sql)
//    }
//}
//class UpdateTests: XCTestCase {
//    func testUpdateGeneric() {
//        let q = Update(Artist.self, set: [.name: "Taylor Swift"])
//        let sql = "UPDATE artists SET artists.name = %s"
//        XCTAssertEqual(compile(q), sql)
//    }
//    
//    func testUpdateLiteral() {
//        let q = Update(Artist.tableName, set: [Artist.f(.name): "Taylor Swift"])
//        let sql = "UPDATE artists SET artists.name = %s"
//        XCTAssertEqual(compile(q), sql)
//    }
//    func testUpdateVariable() {
//        let name = "Taylor Swift"
//        let q = Update(Artist.tableName, set: [Artist.f(.name): name])
//        let sql = "UPDATE artists SET artists.name = %s"
//        XCTAssertEqual(compile(q), sql)
//    }
//    
//    func testUpdateNilVariable() {
//        let name: String? = nil
//        let q = Update(Artist.tableName, set: [Artist.f(.name): name])
//        let sql = "UPDATE artists SET artists.name = NULL"
//        XCTAssertEqual(compile(q), sql)
//    }
//    
//    func testUpdateNilLiteral() {
//        let q = Update(Artist.tableName, set: [Artist.f(.name): nil])
//        let sql = "UPDATE artists SET artists.name = NULL"
//        XCTAssertEqual(compile(q), sql)
//    }
//    
//    func testUpdateSubquery() {
//        let genre = Select(.id, from: Genre.self).asSubquery()
//        let q = Update(Artist.tableName, set: [Artist.f(.name): genre])
//        let sql = "UPDATE artists SET artists.name = ( SELECT genres.id FROM genres )"
//        XCTAssertEqual(compile(q), sql)
//    }
//    
//}
//class ConditionsTests: XCTestCase {
//    func testConditionsBindVariable() {
//        let v = "asd2"
//        let q = Select(from: Artist.self).filter(field("asd")==v)
//        let sql = "SELECT * FROM artists WHERE asd = %s"
//        XCTAssertEqual(compile(q), sql)
//    }
//    
//    func testConditionsBindLiteral() {
//        let q = Select(from: Artist.self).filter(field("asd")=="asd2")
//        let sql = "SELECT * FROM artists WHERE asd = %s"
//        XCTAssertEqual(compile(q), sql)
//    }
//    
//    func testConditionsOtherField() {
//        let q = Select(from: Artist.self).filter(field("asd")==field("asd2"))
//        let sql = "SELECT * FROM artists WHERE asd = asd2"
//        XCTAssertEqual(compile(q), sql)
//    }
//    
//    func testConditionsBindSubquery() {
//        let subq = Select(from: Artist.self).asSubquery()
//        let q = Select(from: Artist.self).filter(field("asd")==subq)
//        let sql = "SELECT * FROM artists WHERE asd = ( SELECT * FROM artists )"
//        XCTAssertEqual(compile(q), sql)
//    }
//    
//}


//    func testCase() {
//        let cases = Case([
//                             Artist.f(.sex)==1: "man",
//                             Artist.f(.sex)==2: "woman",
//                             Artist.f(.sex)<0: "cat",
//        ], _else: "don't know").alias("sex")
//        let q = Select(cases, from:"nil")
//        print(compile(q))
//
//    }
