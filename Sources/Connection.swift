//
//  Connection.swift
//  SwiftSQL
//
//  Created by David Ask on 08/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//

import SwiftFoundation

public protocol ConnectionInfoStringConvertible {
    var connectionString: String { get }
}

public class ConnectionInfo {
    
    public struct Credentials {
        public var username: String
        public var password: String?
        
        public init(username: String, password: String?) {
            self.username = username
            self.password = password
        }
    }
    
    public enum Error : ErrorType {
        case MissingHost
        case MissingPort
    }
    
    public var host: String
    public var port: UInt
    public var databaseName: String?
    public var credentials: Credentials?
    
    public init(host: String, port: UInt, databaseName: String?, credentials: Credentials? = nil) {
        self.host = host
        self.port = port
        self.databaseName = databaseName
        self.credentials = credentials
    }
    
    public convenience init(url: URL) throws {
        
        var credentials: Credentials?
        
        if let username = url.user {
            credentials = Credentials(username: username, password: url.password)
        }
        
        guard let host = url.host else {
            throw Error.MissingHost
        }
        
        guard let port = url.port else {
            throw Error.MissingPort
        }
        
        self.init(
            host: host,
            port: port,
            databaseName: url.path,
            credentials: credentials
        )
    }
}

public typealias ConnectionBlock = (connection: Connection) throws -> Void

public protocol Connection {
    
    typealias ConnectionInfoType : ConnectionInfo, ConnectionInfoStringConvertible
    typealias ResultType : Result
    typealias StatusType
    
    func open(connectionInfo: ConnectionInfoType) throws
    
    func close()
    
    func begin() throws
    func commit() throws
    func rollback() throws
    
    var status: StatusType { get }
    
    func openCursor(name: String, query: Query) throws
    
    func closeCursor(name: String) throws
    
    func withCursor(name: String, query: Query, block: ConnectionBlock) throws
    
    func withTransaction(block: ConnectionBlock) throws
    
    func execute(query: Query) throws -> ResultType
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
    
    public func withTransaction(block: ConnectionBlock) throws {
        try begin()
        
        do {
            try block(connection: self)
            try commit()
        }
        catch {
            try rollback()
            throw error
        }
    }
    
    public func withCursor(name: String, query: Query, block: ConnectionBlock) throws {
        try openCursor(name, query: query)
        
        do {
            try block(connection: self)
        }
        catch {
            try closeCursor(name)
            throw error
        }
        
        try closeCursor(name)
    }
}