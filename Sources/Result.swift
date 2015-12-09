//
//  Result.swift
//  SwiftSQL
//
//  Created by David Ask on 08/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//


public protocol ResultStatus {
    var successful: Bool { get }
}

public protocol Result : GeneratorType {
    typealias ResultStatusType : ResultStatus
    
    var status: ResultStatusType { get }
    
    func clear()
    
    var numberOfRows: Int { get }
    
    var numberOfFields: Int { get }
    
    var fieldNames: [String] { get }
    
    var numberOfAffectedRows: Int { get }
}