// Value.swift
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

public struct ValueConversionError: ErrorProtocol {
    let description: String
}

public enum SQLData {
    case Text(String)
    case Binary(Data)
}

public protocol SQLDataConvertible {
    var sqlData: SQLData { get }

    init(rawSQLData: Data) throws
}

extension Int: SQLDataConvertible {
    public init(rawSQLData data: Data) throws {
        guard let value = Int(try String(xData: data)) else {
            throw ValueConversionError(description: "Failed to convert data to Int")
        }
        self = value
    }

    public var sqlData: SQLData {
        return .Text(String(self))
    }
}

extension UInt: SQLDataConvertible {
    public init(rawSQLData data: Data) throws {
        guard let value = UInt(try String(xData: data)) else {
            throw ValueConversionError(description: "Failed to convert data to UInt")
        }
        self = value
    }

    public var sqlData: SQLData {
        return .Text(String(self))
    }
}

extension Float: SQLDataConvertible {
    public init(rawSQLData data: Data) throws {
        guard let value = Float(try String(xData: data)) else {
            throw ValueConversionError(description: "Failed to convert data to Float")
        }
        self = value
    }

    public var sqlData: SQLData {
        return .Text(String(self))
    }
}

extension Double: SQLDataConvertible {
    public init(rawSQLData data: Data) throws {
        guard let value = Double(try String(xData: data)) else {
            throw ValueConversionError(description: "Failed to convert data to Double")
        }
        self = value
    }

    public var sqlData: SQLData {
        return .Text(String(self))
    }
}

extension String: SQLDataConvertible {
    public init(rawSQLData data: Data) throws {
        try self.init(xData: data)
    }

    public var sqlData: SQLData {
        return .Text(self)
    }
}

extension Data: SQLDataConvertible {
    public init(rawSQLData data: Data) throws {
        self = data
    }

    public var sqlData: SQLData {
        return .Binary(self)
    }
}
