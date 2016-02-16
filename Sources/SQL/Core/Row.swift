// Row.swift
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

@_exported import Data
@_exported import String

public protocol RowType {
    init(dataByFieldName: [String: Data?])

    var fieldNames: [String] { get }

    var dataByFieldName: [String: Data?] { get }
}

public struct Row: RowType, CustomStringConvertible {

    public init(dataByFieldName: [String: Data?]) {
        self.dataByFieldName = dataByFieldName
    }

    public var dataByFieldName: [String: Data?]

    public var fieldNames: [String] {
        return Array(dataByFieldName.keys)
    }
}

public enum RowError: ErrorType {
    case ExpectedField(String)
    case UnexpectedNilValue(String)
    case ConversionError(fieldName: String, type: Any.Type)
}

public extension RowType {

    // MARK: - Data

    public func data(fieldName: String) throws -> Data? {

        /*
         Supplying a fielName can done either
         1. Qualified, e.g. 'users.id'
         2. Non-qualified e.g. 'id'

         A statement will cast qualified fields from 'users.id' to 'users__id'

         Because of this, a given field name must be checked for three type of keys

         */
        var fieldNameCandidates = [fieldName]

        let components = fieldName.split(".")
        if components.count == 2 { // The field name is qualified
            fieldNameCandidates += [
                components.joinWithSeparator("__"), // Add candidate as 'users__id'
                components[1] // Add candidate as 'id'
            ]
        }

        var data: Data??

        for fielNameCandidate in fieldNameCandidates {
            data = dataByFieldName[fielNameCandidate]

            if data != nil {
                break
            }
        }

        guard let result = data else {
            throw RowError.ExpectedField(fieldNameCandidates.joinWithSeparator(", "))
        }
        return result
    }

    public func data(fieldName: String) throws -> Data {
        guard let data: Data = try data(fieldName) else {
            throw RowError.UnexpectedNilValue(fieldName)
        }

        return data
    }

    // MARK: - ValueConvertible

    public func value<T: ValueConvertible>(fieldName: String) throws -> T? {
        guard let data: Data = try data(fieldName) else {
            return nil
        }

        return try T(rawSQLValue: data)
    }

    public func value<T: ValueConvertible>(fieldName: String) throws -> T {
        guard let data: Data = try data(fieldName) else {
            throw RowError.UnexpectedNilValue(fieldName)
        }

        return try T(rawSQLValue: data)
    }


    // MARK: - Model field support

    public func data<F: ModelFieldset>(field: F) throws -> Data? {
        return try data(field.qualifiedName)
    }

    public func data<F: ModelFieldset>(field: F) throws -> Data {
        return try data(field.qualifiedName)
    }

    public func value<T: ValueConvertible, F: ModelFieldset>(field: F) throws -> T? {
        return try value(field.qualifiedName)
    }

    public func value<T: ValueConvertible, F: ModelFieldset>(field: F) throws -> T {
        return try value(field.qualifiedName)
    }


    public var description: String {
        var string: String = ""

        let tab = "\t\t"

        string += dataByFieldName.keys.joinWithSeparator(tab)
        string += "\n---------\n"
        string += dataByFieldName.values.map {
            value in

            guard let value = value else {
                return "NULL"
            }

            return value.description

            }.joinWithSeparator(tab)

        return string
    }
}