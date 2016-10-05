import Axis

public enum Value {
    case string(String)
    case buffer(Buffer)
}

public struct ValueError: Error {
	let description: String
}

public protocol ValueConvertible: ParameterConvertible {
    var sqlValue: Value { get }

    init(rawSQLData: Buffer) throws
}

extension ValueConvertible {
    public var sqlParameter: Parameter {
        return .value(self.sqlValue)
    }
}


extension Int: ValueConvertible {
    public init(rawSQLData buffer: Buffer) throws {
        guard let value = Int(try String(buffer: buffer)) else {
            throw ValueError(description: "Failed to convert data to Int")
        }
        self = value
    }

    public var sqlValue: Value {
        return .string(String(self))
    }
}

extension UInt: ValueConvertible {
    public init(rawSQLData buffer: Buffer) throws {
        guard let value = UInt(try String(buffer: buffer)) else {
            throw ValueError(description: "Failed to convert data to UInt")
        }
        self = value
    }

    public var sqlValue: Value {
        return .string(String(self))
    }
}

extension Float: ValueConvertible {
    public init(rawSQLData buffer: Buffer) throws {
        guard let value = Float(try String(buffer: buffer)) else {
            throw ValueError(description: "Failed to convert data to Float")
        }
        self = value
    }

    public var sqlValue: Value {
        return .string(String(self))
    }
}

extension Double: ValueConvertible {
    public init(rawSQLData buffer: Buffer) throws {
        guard let value = Double(try String(buffer: buffer)) else {
            throw ValueError(description: "Failed to convert data to Double")
        }
        self = value
    }

    public var sqlValue: Value {
        return .string(String(self))
    }
}

extension String: ValueConvertible {
    public init(rawSQLData buffer: Buffer) throws {
        try self.init(buffer: buffer)
    }

    public var sqlValue: Value {
        return .string(self)
    }
}

extension Buffer: ValueConvertible {
    public init(rawSQLData buffer: Buffer) throws {
        self = buffer
    }

    public var sqlValue: Value {
        return .buffer(self)
    }
}
