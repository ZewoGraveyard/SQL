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

public protocol Result : SequenceType {
    typealias ResultStatusType : ResultStatus
    typealias FieldType : Field
    
    var status: ResultStatusType { get }
    
    func clear()
    
    var countAffected: Int { get }
    
    var fields: [FieldType] { get }
}
