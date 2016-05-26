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

public enum Value {
    public struct Error: ErrorProtocol {
        let description: String
    }
    
    case string(String)
    case data(Data)
}

public protocol ValueConvertible: ParameterConvertible {
    var sqlValue: Value { get }

    init(rawSQLData: Data) throws
}

extension ValueConvertible {
    public var sqlParameter: Parameter {
        return .value(self.sqlValue)
    }
}


extension Int: ValueConvertible {
    public init(rawSQLData data: Data) throws {
        guard let value = Int(try String(data: data)) else {
            throw Value.Error(description: "Failed to convert data to Int")
        }
        self = value
    }

    public var sqlValue: Value {
        return .string(String(self))
    }
}

extension UInt: ValueConvertible {
    public init(rawSQLData data: Data) throws {
        guard let value = UInt(try String(data: data)) else {
            throw Value.Error(description: "Failed to convert data to UInt")
        }
        self = value
    }

    public var sqlValue: Value {
        return .string(String(self))
    }
}

extension Float: ValueConvertible {
    public init(rawSQLData data: Data) throws {
        guard let value = Float(try String(data: data)) else {
            throw Value.Error(description: "Failed to convert data to Float")
        }
        self = value
    }

    public var sqlValue: Value {
        return .string(String(self))
    }
}

extension Double: ValueConvertible {
    public init(rawSQLData data: Data) throws {
        guard let value = Double(try String(data: data)) else {
            throw Value.Error(description: "Failed to convert data to Double")
        }
        self = value
    }

    public var sqlValue: Value {
        return .string(String(self))
    }
}

extension String: ValueConvertible {
    public init(rawSQLData data: Data) throws {
        try self.init(data: data)
    }

    public var sqlValue: Value {
        return .string(self)
    }
}

extension Data: ValueConvertible {
    public init(rawSQLData data: Data) throws {
        self = data
    }

    public var sqlValue: Value {
        return .data(self)
    }
}
