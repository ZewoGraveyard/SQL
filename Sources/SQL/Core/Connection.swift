// Connection.swift
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

@_exported import URI
@_exported import Log

public protocol ConnectionStringConvertible : StringLiteralConvertible {
    init(connectionString: String)

    var connectionString: String { get }
}

public extension ConnectionStringConvertible {
    public init(stringLiteral: String) {
        self.init(connectionString: stringLiteral)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(connectionString: value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(connectionString: value)
    }
    
    public var description: String {
        return connectionString
    }
}

public protocol ConnectionInfo: ConnectionStringConvertible {
    var user: String? { get set }
    var password: String? { get set }
    var host: String { get set }
    var port: Int { get set }
    var database: String { get set }
    
    init(host: String, database: String, port: Int?, user: String?, password: String?)
}

public extension ConnectionInfo {
    
    public init(connectionString: String) {
        guard let uri = try? URI(string: connectionString) else {
            fatalError("Failed to construct URI from \(connectionString)")
        }
        
        guard let host = uri.host else {
            fatalError("Missing host in connection string")
        }
        
        guard let database = uri.path?.split("/").last else {
            fatalError("Missing database in connection string")
        }
        
        self.init(
            host: host,
            database: database,
            port: uri.port,
            user: uri.userInfo?.username,
            password: uri.userInfo?.password
        )
    }
}


public protocol Connection {
    associatedtype ConnectionInfoType: ConnectionInfo, ConnectionStringConvertible
    associatedtype ResultType: Result
    associatedtype StatusType
    associatedtype Error: ErrorType

    var connectionInfo: ConnectionInfoType { get }

    func open() throws

    func close()

    var status: StatusType { get }

    var log: Log? { get set }

    func execute(statement: Statement) throws -> ResultType

    func begin() throws

    func commit() throws

    func rollback() throws

    func createSavePointNamed(name: String) throws

    func releaseSavePointNamed(name: String) throws

    func rollbackToSavePointNamed(name: String) throws

    init(_ connectionInfo: ConnectionInfoType)
    
    var mostRecentError: Error? { get }
}

public extension Connection {

    public func transaction(block: Void throws -> Void) throws {
        try begin()

        do {
            try block()
            try commit()
        }
        catch {
            try rollback()
            throw error
        }
    }

    public func withSavePointNamed(name: String, block: Void throws -> Void) throws {
        try createSavePointNamed(name)

        do {
            try block()
            try releaseSavePointNamed(name)
        }
        catch {
            try rollbackToSavePointNamed(name)
            try releaseSavePointNamed(name)
            throw error
        }
    }
    
    public func execute(statement: Statement) throws -> ResultType {
        return try execute(statement)
    }

    public func execute(convertible: StatementConvertible) throws -> ResultType {
        return try execute(convertible.statement)
    }

    public func executeFromFile(atPath path: String) throws -> ResultType {
        return try execute(
            Statement(try String(data: File(path: path).read()))
        )
    }

    public func begin() throws {
        try execute("BEGIN")
    }

    public func commit() throws {
        try execute("COMMIT")
    }

    public func rollback() throws {
        try execute("ROLLBACK")
    }
}
