// MigrationManager.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Formbound
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@_exported import File

public struct MigrationError: ErrorType {
    public let description: String
}

public struct Migration {
    public let upStatement: String
    public let downStatement: String?

    public init(path: String) throws {

        var path = path

        if path.characters.last == "/" {
			path = String(path.characters.dropLast())
        }

        let upPath = path + "/up.sql"
        let downPath = path + "/down.sql"

        var isDirectory: Bool = false

        guard File.fileExistsAtPath(upPath, isDirectory: &isDirectory) && !isDirectory else {
            throw MigrationError(description: "up.sql not found at \(upPath)")
        }


        self.upStatement = try String(data: File(path: upPath).read())

        if File.fileExistsAtPath(downPath, isDirectory: &isDirectory) && !isDirectory {
            self.downStatement = try String(data: File(path: downPath).read())
        }
        else {
            self.downStatement = nil
        }
    }
}


public class MigrationManager<T: Connection> {

    public let connection: T

    private(set) public var migrationsByNumber: [Int: Migration] = [:]

    public init(migrationsDirectory path: String, connection: T) throws {

        self.connection = connection

        try connection.execute("CREATE TABLE IF NOT EXISTS schema_migrations (timestamp TIMESTAMP(6) NOT NULL, from_version SMALLINT, to_version SMALLINT NOT NULL)")

        var path = path

        if path.characters.last == "/" {
			path = String(path.characters.dropLast())
        }

        var isDirectory: Bool = false

        guard File.fileExistsAtPath(path, isDirectory: &isDirectory) && isDirectory else {
            throw MigrationError(description: "Unable to open find migrations directory at \(path)")
        }

        let directories = try File.contentsOfDirectoryAtPath(path).filter {
            path in

            return path.split(".").last == "migration"
		}.sort()

        guard !directories.isEmpty else {
            throw MigrationError(
                description: "No migrations found at \(path). Create folders named 'xx.migration' containing an 'up.sql' file, and optionally a 'down.sql' file \(path)"
            )
        }

        for (i, directoryPath) in directories.enumerate() {
            migrationsByNumber[i + 1] = try Migration(path: path + "/" + directoryPath)
        }

    }

    public var currentVersion: Int? {
        guard let result = try? connection.execute("SELECT * FROM schema_migrations ORDER BY timestamp DESC LIMIT 1") else {
            return nil
        }

        return (try? result.first?.value("to_version")) ?? nil
    }

    public var latestVersion: Int? {
        return migrationsByNumber.keys.sort().last
    }

    public func migrate(to targetVersion: Int) throws {

        guard let latestVersion = latestVersion else {
            throw MigrationError(description: "No migrations defined")
        }

        guard targetVersion >= 0 && targetVersion <= latestVersion else {
            throw MigrationError(description: "Target version out of range")
        }

        let currentVersion = self.currentVersion

        var fromVersion = currentVersion ?? 0

        if currentVersion == targetVersion {
            return
        }

        while fromVersion != targetVersion {
            try connection.transaction {

                // Are we migrating up or down?
                let upDirection = fromVersion < targetVersion

                // The next predicted version
                let nextVersion = upDirection ? fromVersion + 1 : fromVersion - 1

                /*
                The number of the migration we're either reading the up or down statement from

                If the current version is *1*, and we're migrating up to *2*, we're executing the *up* statement of the migration with number *2*
                If the current version is *1*, and we're migrating down to 0 we're executing the *down* statement of the migration with number *1*
                */
                let migrationNumber = upDirection ? nextVersion : nextVersion + 1

                guard let migration = self.migrationsByNumber[migrationNumber] else {
                    throw MigrationError(
                        description: "Cannot migrate to version \(nextVersion). The migration with number \(migrationNumber) does not exist."
                    )
                }

                if upDirection {

                    try self.connection.execute(Statement(migration.upStatement))
                }
                else {
                    guard let downStatement = migration.downStatement else {
                        throw MigrationError(
                            description: "Cannot migrate to version \(nextVersion). The migration with number \(migrationNumber) has no down statement."
                        )
                    }

                    try self.connection.execute(Statement(downStatement))
                }

                try self.connection.execute(
                    Statement("INSERT INTO schema_migrations (timestamp, from_version, to_version) VALUES(CURRENT_TIMESTAMP(6), $1, $2)",
                    parameters: [fromVersion, nextVersion])
                )

                guard let currentVersion = self.currentVersion else {
                    throw MigrationError(
                        description: "Failed to get current version of migration."
                    )
                }

                guard nextVersion == currentVersion else {
                    throw MigrationError(
                        description: "The predicted next version(\(nextVersion)) does not match the current version (\(currentVersion)). Semething is wrong, possibly a bug!"
                    )
                }

                fromVersion = currentVersion

            }
        }
    }
}
