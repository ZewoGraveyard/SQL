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

@_exported import Log
import C7


public protocol ConnectionInfo {
    var host: String { get }
    var port: Int { get }
    var databaseName: String { get }
    var username: String? { get }
    var password: String? { get }
}

public protocol Connection: class, C7.Connection {
    associatedtype Info: ConnectionInfo
    associatedtype ResultType: Result
    associatedtype StatusType
    associatedtype Error: ErrorProtocol

    var connectionInfo: Info { get }

    var status: StatusType { get }

    var log: Log? { get set }

    func execute(statement: QueryComponents) throws -> ResultType

    func begin() throws

    func commit() throws

    func rollback() throws

    func createSavePointNamed(name: String) throws

    func releaseSavePointNamed(name: String) throws

    func rollbackToSavePointNamed(name: String) throws

    init(_ info: Info)
    
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
    
    public func execute(statement: QueryComponents) throws -> ResultType {
        return try execute(statement)
    }
    
    public func execute(statement: String, parameters: [SQLDataConvertible?] = []) throws -> ResultType {
        return try execute(QueryComponents(statement, values: parameters.map { $0?.sqlData }))
    }
    
    public func execute(statement: String, parameters: SQLDataConvertible?...) throws -> ResultType {
        return try execute(statement, parameters: parameters)
    }

    public func execute(convertible: QueryComponentsConvertible) throws -> ResultType {
        return try execute(convertible.queryComponents)
    }

    public func executeFromFile(atPath path: String) throws -> ResultType {
        return try execute(
            QueryComponents(try String(data: File(path: path).read()))
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
