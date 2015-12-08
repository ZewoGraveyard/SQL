//
//  Result.swift
//  SwiftSQL
//
//  Created by David Ask on 08/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//

import SwiftFoundation

public protocol ResultStatus {
    var successful: Bool { get }
}

public protocol Result{
    typealias ResultStatusType : ResultStatus
    
    var status: ResultStatusType { get }
    
    func clear()
    
    var numberOfRows: Int { get }
    
    var fieldNames: [String] { get }
}