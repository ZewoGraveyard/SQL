// ConnectionProtocol.swift
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


/**
 *  ConnectionInfoProtocol is an adapter-specific protocol that holds necessary
 *  values to connect to a database. Associated with `ConnectionProtocol.ConnectionInfo`
 */
public protocol ConnectionInfoProtocol {
    var host: String { get }
    var port: Int { get }
    var databaseName: String { get }
    var username: String? { get }
    var password: String? { get }
    
    init?(uri: URI)
}

public protocol ConnectionProtocol: class {
    associatedtype InternalStatus
    associatedtype Result: ResultProtocol
    associatedtype Error: ErrorProtocol, CustomStringConvertible
    associatedtype ConnectionInfo: ConnectionInfoProtocol
    associatedtype QueryRenderer: QueryRendererProtocol
    
    var connectionInfo: ConnectionInfo { get }

    func open() throws

    func close()

    var internalStatus: InternalStatus { get }
    
    func execute(_ statement: String, parameters: [Value?]?) throws -> Result

    func begin() throws

    func commit() throws

    func rollback() throws

    func createSavePointNamed(_ name: String) throws

    func releaseSavePointNamed(_ name: String) throws

    func rollbackToSavePointNamed(_ name: String) throws

    init(info: ConnectionInfo)
    
    var mostRecentError: Error? { get }
}

public extension ConnectionProtocol {
    
    public init?(uri: URI) {
        guard let info = ConnectionInfo(uri: uri) else {
            return nil
        }
        self.init(info: info)
    }

    public func transaction<T>(handler: (Void) throws -> T) throws -> T {
        try begin()
        
        do {
            let result = try handler()
            try commit()
            return result
        }
        catch {
            try rollback()
            throw error
        }
    }

    public func withSavePointNamed(_ name: String, block: (Void) throws -> Void) throws {
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
    
    func execute(_ statement: String) throws -> Result {
        return try execute(statement, parameters: nil)
    }
    
    public func execute(_ query: Select) throws -> Result {
        return try execute(QueryRenderer.renderStatement(query), parameters: query.sqlParameters)
    }
    
    public func execute(_ query: Update) throws -> Result {
        return try execute(QueryRenderer.renderStatement(query), parameters: query.sqlParameters)
    }
    
    public func execute(_ query: Insert, returnInsertedRows: Bool = false) throws -> Result {
        return try execute(QueryRenderer.renderStatement(query, forReturningInsertedRows: returnInsertedRows), parameters: query.sqlParameters)
    }
    
    public func execute(_ query: Delete) throws -> Result {
        return try execute(QueryRenderer.renderStatement(query), parameters: query.sqlParameters)
    }
    
    public func execute(_ statement: String, parameters: [ValueConvertible?]) throws -> Result {
        return try execute(statement, parameters: parameters.map { $0?.sqlValue })
    }
    
    public func execute(_ statement: String, parameters: ValueConvertible?...) throws -> Result {
        return try execute(statement, parameters: parameters)
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
