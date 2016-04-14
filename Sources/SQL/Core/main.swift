extension Table {
    public static func f(field: Field) -> DeclaredField {
        return self.field(field)
    }
}


struct Artist {
    let id: Int?
    // Note the optionality. Fields that are marked `NOT NULL` in your schema should be non-optional.
    var name: String
    var genre: String?

    // You probably want your own initializer
    init(name: String, genre: String) {
        self.id = nil
        self.name = name
        self.genre = genre
    }
}


extension Artist: Table {
    // Define the fields of your model.
    // Make sure to name it `Field` and have it conform to `String` and `FieldType`

    enum Field: String, FieldType {
        case Id = "id"
        case Name = "name"
        case Genre = "genre"
        case salary1, salary2, salary3
    }

    // Table name corresponding to your model
    static let tableName: String = "artists"

    // The field for the primary key of the model
    static let fieldForPrimaryKey: Field = .Id


}

struct Event: Table {

    enum Field: String, FieldType {
        case id = "id", name
    }

    static let tableName: String = "events"
    static let fieldForPrimaryKey: Field = .id
}

struct Component: Table {
    enum Field: String, FieldType {
        case id = "id", eventId = "event_id"
    }
    static let tableName: String = "components"
    static let fieldForPrimaryKey: Field = .id

}

// Pass table name as type, field as .field
//let q = Select(.Name, .Genre, from: Artist.self)



// Custom alias for field
//let q = Select(Artist.f(.Name).alias("asd"), from: Artist.tableName)

// Chaining selects
//let q = Select(.Name, from: Artist.self)
//if cond {
//    q1 = q.select("field", "otherfield")
//}


// Pass table name as type, field as .field
//let q = Insert([.id: 12, .eventId: "asd"], into: Component.self)

// Inserting value from subquery
//let eventId = Select(.id, from: Event.self).filter(Event.f(.name)=="name")
//let q = Insert([.id: 12, .eventId: eventId], into: Component.self)

//group by
//let q = Select(Event.f(.id), Event.f(.name), from: Event.self).groupBy(Event.f(.id), Event.f(.id))


//case
//let cases = Case([
//        (Event.f(.id)>5 && Event.f(.name) < "asd", "asd"),
//        (Event.f(.id)<5, "3123")
//], _else: "32").alias("username")


//case as select field
//let q = Select(cases, "asdA", Event.f(.id).alias("event_id"), from: "nil")


//subqueries in joins, aliasing, subqery.field
//let events = Select(from: Event.self).asSubquery("ev")
//let q = Select(from: Event.tableName).join(events, type: .Inner, leftKey: Event.f(.id), rightKey: events.field("id"))


//subqueries in select
//let someevent = Select(Event.f(.name), from: Event.tableName).filter(Event.f(.id)==1).asSubquery("ev")
//let q = Select(someevent, from: Event.tableName)







//let q = Select(Event.f(.id)+"  "+Event.f(.name), from: Event.self)


let subq = Select(Event.f(.id), from: Event.tableName).asSubquery()

//let q = Select(subq, Event.f(.name), from: Event.tableName).groupBy("asd", "fdsd").join(subq, using: [.Inner, .Left],
//        leftKey: "asd2", rightKey: subq.field("asd")).orderBy(.Ascending("asd")).limit(1000).offset(12)



let d2 = "asdsa"

//extension QueryComponentRepresentable:StringLiteralConvertible {
//
//}

let q = Select(Event.f(.id), from: "asdasd").filter(field("asdas") == "fdsdasf" && "f" == d2.sqlData )

//print(q.queryComponent)


//let q = Delete(from: "table").filter("asdsa" == nil)

let q2 = Insert([Event.f(.id): subq, "naame": subq], into: "asd")


//let q = Update("table", set: ["name": subq]).filter("asd"==Func.count(d2, "secondarg") && "asd" == "fds2")

print(Compiler().compile(q))
print(Compiler().compile(q2))













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