//
//  Field.swift
//  SQL
//
//  Created by David Ask on 09/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//

public protocol Field: CustomStringConvertible {
    var name: String { get }
}

public extension Field {
    public var description: String {
        return name
    }
}
