//
//  Connection.swift
//  SQL
//
//  Created by David Ask on 08/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//


import Foundation

public class ConnectionInfo {

    public var user: String?
    public var password: String?
    public var host: String
    public var port: UInt
    public var database: String
    
    
    public init(host: String, database: String, port: UInt, user: String? = nil, password: String? = nil) {
        self.host = host
        self.database = database
        self.port = port
        self.user = user
        self.password = password
    }
}

public protocol Connection {
    
    typealias ConnectionInfoType: ConnectionInfo, StringLiteralConvertible
    typealias ResultType: Result
    typealias StatusType
    
    var connectionInfo: ConnectionInfoType { get }
    
    func open() throws
    
    func close()
    
    var status: StatusType { get }
    
    func execute(string: String) throws -> ResultType
    
    func begin() throws
    
    func commit() throws
    
    func rollback() throws
    
    func createSavePointNamed(name: String) throws
    
    func releaseSavePointNamed(name: String) throws
    
    func rollbackToSavePointNamed(name: String) throws
    
    init(_ connectionInfo: ConnectionInfoType)
}

public extension Connection {
    
    public func query(string: String) throws {
        try execute(string)
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
    
    public subscript(string: String) -> (ErrorType?, ResultType?) {
        do {
            return (nil, try execute(string))
        }
        catch {
            return (error, nil)
        }
    }
}