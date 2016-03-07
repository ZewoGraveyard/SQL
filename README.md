SQL
====

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://swift.org)
[![Platforms Linux](https://img.shields.io/badge/Platforms-Linux-lightgray.svg?style=flat)](https://swift.org)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license)
[![Slack Status](http://slack.zewo.io/badge.svg)](http://slack.zewo.io)

**SQL** provides base conformance for SQL adapters.


## Installation

The SQL module is bundled with the SQL adapters of Zewo

* [Postgres](https://github.com/Zewo/PostgreSQL)
* [MySQL](https://github.com/zewo/MySQL)



## Connecting to a database
Each library conforming to `SQL` implements its own method of connecting. In PostgreSQL it looks like this

```swift
let connection = Connection(host: "localhost", databaseName: "my_database")
```

Each driver should have a `Connection` constructor you can use to provide connection details.

## Opening and closing a connection

Opening a connection is easy.

```swift
try connection.open()
```

Closing is usually not needed, as the connection will close automatically when there are no references to the connection class. You can, however, do it manually.

```swift
connection.close()
```


## Executing raw queries
You can run queries simply by passing a `String` to the connections `execute` method.

```swift
try connection.execute("SELECT * FROM artists")
```

You can pass parameters to protect your queries from [SQL injection](https://en.wikipedia.org/wiki/SQL_injection).

```swift
try connection.execute("SELECT * FROM artists where id = %@", parameters: 1)
```

## Getting values from results

When executing queries, using the  `execute` method, you will receive a `Result` object for your specific driver.
The `Result` object is a `CollectionType` that may or may not contain generator elements of `Row`.

```swift
for row in try connection.execute("SELECT * FROM artists") {
    let name: String = try row.value("name")
    let data = try row.data("name")
}
```

When accessing values from a `Row`, you can either ask for a value or `Data`. When asking for a value, you need to explicitly declare the type of the value you are expecting, including if it's optional or not. This helps with the data integrity of your application, as `Row` will throw an error if it finds a null value where you've declared a non-optional type. Similarly, `Row` will throw an error if the field is not present in the result.

## Using the standard query methods

If you do not want an ORM-style query builder, SQL allows you to build your queries with a simple syntax.

### SELECT

```swift
// Select specified fields
Select(["id", "name"], from: "artists")

// Select all fields
Select(from: "artists")

// Limit to one result
Select(["id", "name"], from: "artists").first

// Join
Select(from: "artists").join("albums", using: .Inner, leftKey: "artists.id", rightKey: "albums.artist_id")

// Limit & Offset
Select(from: "artists").limit(10).offset(1)

// Ordering
Select(from: "artists").orderBy(.Descending("name"), .Ascending("id"))
```

You can chain most methods, ending up with a query that looks like this.

```swift
let result = try Select(from: "artists")
    .join("albums", using: .Inner, leftKey: "artists.id", rightKey: "albums.artist_id")
    .offset(1)
    .limit(1)
    .orderBy(.Descending("name"), .Ascending("id"))
    .execute(connection)
```

### UPDATE

```swift
Update("artists", set: ["name": "Mike Snow"])
```

### DELETE

```swift
Delete(from: "albums")
```

### Filtering queries

`SELECT`, `UPDATE`, and `DELETE` queries can be filtered like so:

```swift
Select(from: "artists").filter(field("id") >= 1 && field("genre") == field("genre") || field("id") == 2)
```

### INSERT

```swift
Insert(["name": "Lady Gaga"], into: "artists")
```

## Running built queries
All built queries have an `execute` method, that takes a `Connection` class ass a parameter.

```swift
try Select(from: "albums").execute(connection)
```

You can also pass the query to `Connection.execute`.

```swift
try connection.execute(Select(from: "albums"))
```

## Creating models

`SQL` has ORM-style functionality, focusing on efficiency, transparency and safety. Your specific driver should have a `Model` protocol, that extends `SQL.Model`. Let's go through how to implement it.

Create your basic model struct. Using structs are good practice, as `SQL` modifies your object when saving and updating by replacing the entire struct. Using a class is not recommended.

```swift
import PostgreSQL

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
```

In order to conform to the `Model` protocol, we have to extend `Artist`. You can put this code directly in your struct if you like.

```swift
extension Artist: Model {
	// Define the fields of your model.
	// Make sure to name it `Field` and have it conform to `String` and `FieldType`
	enum Field: String, FieldType {
	    case Id = "id"
	    case Name = "name"
	    case Genre = "genre"
	}
	
	// Table name corresponding to your model
	static let tableName: String = "artists"
	
	// The field for the primary key of the model
	static let fieldForPrimaryKey: Field = .Id
	    
	// The fields used when constructing your model.
	// You don't have to match all the values in your `Field` enum, unless you want to.
	// NOTE: Leave this out to select all fields.
	static let selectFields: [Field] = [
	    .Id,
	    .Name,
	    .Genre
	]
	
	// The model needs to know the value of your primary key.
	// You can name the actual variable of your struct representing the primary key
	// to `primaryKey`, or provide it like shown below.
	// NOTE: You can use any type as your primary key, as long as it conforms to `SQLDataConvertible`
	var primaryKey: Int? {
		return id
	}
	
	// Add the ability to construct the model from a row
	init(row: Row) throws {
	    id = try row.value(Artist.field(.Id))
	    name = try row.value(Artist.field(.Name))
	    genre = try row.value(Artist.field(.Genre))
	}
	
	// Define which values are allowed to be persisted.
	// Note whether your properties are mutable.
	var persistedValuesByField: [Field: SQLDataConvertible?] {
	    return [
	        .Name: name,
	        .Genre: genre
    ]
    
    // The model needs to know the value of your primary key.
    // You can name the actual variable of your struct representing the primary key
    // to `primaryKey`, or provide it like shown below.
    // NOTE: You can use any type as your primary key, as long as it conforms to `SQLDataConvertible`
    var primaryKey: Int? {
        return id
    }
    
    // Add the ability to construct the model from a row
    init(row: Row) throws {
        id = try row.value(Artist.field(.Id))
        name = try row.value(Artist.field(.Name))
        genre = try row.value(Artist.field(.Genre))
    }
    
    // Define which values are allowed to be persisted.
    // Note whether your properties are mutable.
    var persistedValuesByField: [Field: SQLDataConvertible?] {
        return [
            .Name: name,
            .Genre: genre
        ]
    }
}
```

While this solution is generally more verbose than most ORM's, there's no magic, it's very clear what's going on.
Let's also create an `Album` model.

```swift
struct Album {
    struct Error: ErrorType {
        let description: String
    }
    
    let id: Int?
    var name: String
    var artistId: Int
    
    init(name: String, artist: Artist) throws {
        guard let artistId = artist.id else {
            throw Error(description: "Artist doesn't have an id yet")
        }
        
        self.name = name
        self.artistId = artistId
        self.id = nil
    }
}

extension Album: Model {
    enum Field: String, FieldType {
        case Id = "id"
        case Name = "name"
        case ArtistId = "artist_id"
    }
    
    static let tableName: String = "albums"
    
    static let fieldForPrimaryKey: Field = .Id
    
    static let selectFields: [Field] = [
        .Id,
        .Name,
        .ArtistId
    ]
    
    var primaryKey: Int? {
        return id
    }
    
    init(row: Row) throws {
        id = try row.value(Album.field(.Id))
        name = try row.value(Album.field(.Name))
        artistId = try row.value(Album.field(.ArtistId))
    }
    
    var persistedValuesByField: [Field: SQLDataConvertible?] {
        return [
            .Name: name,
            .ArtistId: artistId
        ]
    }
}
```

After creating our models, we can use a more safe way of creating queries.

### Creating queries

```swift
Artist.select
let artist = Artist.find(1, connection: connection)

Artist.selectQuery.join(Album.self, type: .Inner, leftKey: .Id, rightKey: .ArtistId)

Artist.selectQuery.limit(10).offset(1)

Artist.selectQuery.orderBy(.Descending(.Name), .Ascending(.Id))
```

### Filtering queries

When working with model queries, you use `Model.field()`, specifying your models `Field` enum to get the declared fields.

```swift
Artist.select.filter(Artist.field(.Id) == 1 || Artist.field(.Genre) == "rock")
```

### Fetching & get models

Using model selects, you can call `fetch` and `first`

```swift
let artists = try Artist.select.fetch(connection) // [Artist]

let artist = try Artist.select.first(connection) // Artist?

let artist = try Artist.get(1, connection: connection) // Artist?
```

### Saving models

You can insert new models either by simply providing a dictionary with fields and values

```swift
let artist = try Artist.create([.Name: "AC/DC", .Genre: "rock"], connection: connection)
```

Or, you can construct a model using your own initializers

```swift
var artist = Artist(name: "Kendrick Lamar", genre: "hip hop")
try artist.create(connection)
```

You can simply call `save`

```swift
var artist = Artist(name: "Hocus pocus", genre: "hip hop")
try artist.save(connection)
```

`save` will either call `insert` or `update` depending on whether the model has a primary key.

### Deleting models

```swift
try artist.delete(connection: connection)
```

### Validating before save/create
Add a method with the following signature to your models. Throw an error if validation failed. Not throwing an error indicates that the validation passed.

Validations are called before `willSave()`, `willUpdate()`, and `willCreate()`

```swift
func validate()throws {
	guard name == "david" else {
		throw MyError("Name has to be 'david'")
	}
}
```

### Hooks
You can use any of the following hooks in your model. 

```swift
func willSave()
func didSave()
    
func willUpdate()
func didUpdate()
    
func willCreate()
func didCreate()
    
func willDelete()
func didDelete()
    
func willRefresh()
func didRefresh()
```

For updates the flow is: `willSave() -> willUpdate -> (UPDATE) -> didUpdate() -> willRefresh() -> (REFRESH) -> didRefresh() -> didSave()` For creates, the flow is similar, except the `updates` are `creates`.

### Change tracking for performance 

By default, a `Model` will update all fields as defined in its `persistedValuesByField` property. If you want a more performant solution, you can use *dirty tracking*.

Start by adding a property to your model called `dirtyFields`:

```swift
struct Artist {
	let id: Int?
   	var name: String
   	var genre: String?
   	
   	var changedFields: [Field]? = []
   	
}
```

By default, this property is `nil` which instructs `SQL` to save **all** values. After assigning a non-nil dictionary to your model, you have to tell your model which values to update.

```swift
try artist.setNeedsSave(.Genre)
```

The method will throw an error if your `changedFields` property is nil, warning you that you have not setup dirty tracking.
A convenient way of adding validations, for additional safety in your models  would be to use `willSet/didSet` hooks on your 
properties.

```swift
struct Artist {
	let id: Int?
   	var name: String {
   		didSet {
   			try artist.setNeedsSave(.Name)
   		}
   	}
   	var genre: String? {
   		didSet {
   			try artist.setNeedsSave(.Genre)
   		}
   	}
   	
   	var changedFields: [Field]? = []
   	
}
```

## Community

[![Slack](http://s13.postimg.org/ybwy92ktf/Slack.png)](http://slack.zewo.io)

Join us on [Slack](http://slack.zewo.io).

License
-------

**SQL** is released under the MIT license. See LICENSE for details.
