//
//  Connection.swift
//  SwiftSQL
//
//  Created by David Ask on 08/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//



public protocol ConnectionStringConvertible {
    var connectionString: String { get }
}

public protocol ConnectionStringLiteralConvertible : StringLiteralConvertible {
    init(connectionString: String)
}

public protocol ConnectionInfo : ConnectionStringConvertible, ConnectionStringLiteralConvertible {
    var user: String? { get }
    var password: String? { get }
    var host: String { get }
    var port: UInt { get }
    var database: String { get }
}


public protocol Connection {
    
    typealias ConnectionInfoType : ConnectionInfo
    typealias ResultType : Result
    typealias StatusType
    
    var connectionInfo: ConnectionInfoType { get }
    
    func open() throws
    
    func close()
    
    func begin() throws
    func commit() throws
    func rollback() throws
    
    var status: StatusType { get }
    
    func openCursor(name: String) throws
    
    func closeCursor(name: String) throws
    
    func withCursor(name: String, block: Void throws -> Void) throws
    
    func withTransaction(block: Void throws -> Void) throws
    
    func execute(string: String) throws -> ResultType
    
    init(_ connectionInfo: ConnectionInfoType)
}


public extension Connection {
    public func begin() throws {
        try self.execute("BEGIN")
    }
    
    public func commit() throws {
        try self.execute("COMMIT")
    }
    
    public func rollback() throws {
        try self.execute("ROLLBACK")
    }
    
    public func withTransaction(block: Void throws -> Void) throws {
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
    
    public func withCursor(name: String, block: Void throws -> Void) throws {
        try openCursor(name)
        
        do {
            try block()
        }
        catch {
            try closeCursor(name)
            throw error
        }
        
        try closeCursor(name)
    }
}