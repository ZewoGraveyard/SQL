import Core

public enum Value {
    case string(String)
    case data(Data)
}

public struct ValueError: Error {
	let description: String
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
            throw ValueError(description: "Failed to convert data to Int")
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
            throw ValueError(description: "Failed to convert data to UInt")
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
            throw ValueError(description: "Failed to convert data to Float")
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
            throw ValueError(description: "Failed to convert data to Double")
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
