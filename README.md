# SQL

[![Swift][swift-badge]][swift-url]
[![Zewo][zewo-badge]][zewo-url]
[![Platform][platform-badge]][platform-url]
[![License][mit-badge]][mit-url]
[![Slack][slack-badge]][slack-url]
[![Travis][travis-badge]][travis-url]
[![Codebeat][codebeat-badge]][codebeat-url]

**SQL** provides base conformance for SQL adapters.

## Installation

The SQL module is bundled with the SQL adapters of Zewo

* [Postgres](https://github.com/Zewo/PostgreSQL)
* [MySQL](https://github.com/zewo/MySQL)

```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/Zewo/SQL.git", majorVersion: 0, minor: 13),
    ]
)
```

## Usage

Use this package with one of the supported drivers listed above.

### Connecting to a database

```swift
let connection = try PostgreSQL.Connection(URI("postgres://localhost:5432/swift_test"))
```

### Executing raw queries

```swift
try connection.execute("SELECT * FROM artists")
let result = try connection.execute("SELECT * FROM artists WHERE name = %@", parameters: "Josh Rouse")
```

### Getting results from queries
```swift
let result = try connection.execute("SELECT * FROM artists")

for row in result {
	let name: String = try result.value("name")
	let genre: String? = try result.value("genre")
	print(name)
}
```

In the above example, an error will be thrown if `name` and `genre` is not present in the rows returned. An error will also be thrown if a `name` is `NULL` in any row, as the inferred type is non-optional. Note how `genre` will allow for a `NULL` value.

### Tables

You can define tables as such:

```swift
public class Artist: Table {
	enum Field: String {
        case id = "id"
        case name = "name"
        case artistId = "artist_id"
    }

    static let tableName: String = "artists"
}
```

```swift
Artist.select().filter(Artist.field(.name) == "Josh Rouse")
Artist.insert([.name: "AC/DC"])
Artist.update([.name: "AC/DC"]).filter(Artist.field(.genre) == "Rock")
Artist.delete().filter(Artist.field(.genre) == "Rock")
```

```swift
try connection.execute(Artist.select())
```

### Models
You can define models, by extending `Table` like so:

```swift
public final class Artist {
	let id: Int?
	let name: String
	let genre: String

	init(name: String, genre: String) {
		self.name = name
		self.genre = genre
	}
}

extension Artist: Model {
	// Just like `Table`
	enum Field: String {
	    case id = "id"
	    case name = "name"
	    case genre = "genre"
	}

	// Specify a table name
	static let tableName: String = "artists"

	// Specify which field is primary
	static var primaryKeyField: Field = .id

	// Provide a getter and setter for the primary key
	var primaryKey: Int? {
	    get {
	        return id
	    }
	    set {
	        id = newValue
	    }
	}

	// Specify the values to be persisted
	var serialize: [Field: ValueConvertible?] {
	    return [.name: name, .genre: genre]
	}

	// Provide an initializer for the model taking a row
	convenience init(row: Row) throws {
	    try self.init(
	        name: row.value(Artist.field(.name)),
	        genre: row.value(Artist.field(.genre))
	    )
	    id = try row.value(Artist.field(.id))
	}
}

```

```swift
let rockArtists = try Artist.fetch(where: Artist.field(.genre) == "Rock", connection: connection)

for artist in rockArtists {
	artist.genre = "Rock 'n Roll"
	artist.save()
}

let newArtist = Artist(name: "Elijah Blake", genre: "Hip-hop")
try newArtist.create(connection: connection) // save() also works

```

## Support

If you need any help you can join our [Slack](http://slack.zewo.io) and go to the **#help** channel. Or you can create a Github [issue](https://github.com/Zewo/Zewo/issues/new) in our main repository. When stating your issue be sure to add enough details, specify what module is causing the problem and reproduction steps.

## Community

[![Slack][slack-image]][slack-url]

The entire Zewo code base is licensed under MIT. By contributing to Zewo you are contributing to an open and engaged community of brilliant Swift programmers. Join us on [Slack](http://slack.zewo.io) to get to know us!

## License

This project is released under the MIT license. See [LICENSE](LICENSE) for details.

[swift-badge]: https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat
[swift-url]: https://swift.org
[zewo-badge]: https://img.shields.io/badge/Zewo-0.13-FF7565.svg?style=flat
[zewo-url]: http://zewo.io
[platform-badge]: https://img.shields.io/badge/Platforms-OS%20X%20--%20Linux-lightgray.svg?style=flat
[platform-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
[slack-image]: http://s13.postimg.org/ybwy92ktf/Slack.png
[slack-badge]: https://zewo-slackin.herokuapp.com/badge.svg
[slack-url]: http://slack.zewo.io
[travis-badge]: https://travis-ci.org/Zewo/SQL.svg?branch=master
[travis-url]: https://travis-ci.org/Zewo/SQL
[codebeat-badge]: https://codebeat.co/badges/2548b359-daf1-404b-b5ae-687b98c02101
[codebeat-url]: https://codebeat.co/projects/github-com-zewo-sql
