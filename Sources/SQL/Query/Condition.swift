// Condition.swift
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

public indirect enum Condition: StatementConvertible {
    public enum Key {
        case Value(SQL.Value?)
        case Property(String)
    }

    case Equals(String, Key)

    case GreaterThan(String, Key)
    case GreaterThanOrEquals(String, Key)

    case LessThan(String, Key)
    case LessThanOrEquals(String, Key)


    case In(String, [SQL.Value?])
    case NotIn(String, [SQL.Value?])

    case And([Condition])
    case Or([Condition])

    case Not(Condition)


    public var statement: Statement {

        func statementWithKeyValue(key: String, _ op: String, _ value: Key) -> Statement {
            switch value {
            case .Value(let value):
                return Statement("\(key) \(op) \(Statement.parameterPlaceholder)", parameters: [value])
            case .Property(let name):
                return Statement("\(key) \(op) \(name)", parameters: [])
            }
        }

        switch self {
        case .Equals(let key, let value):
            return statementWithKeyValue(key, "=", value)

        case .GreaterThan(let key, let value):
            return statementWithKeyValue(key, ">", value)

        case .GreaterThanOrEquals(let key, let value):
            return statementWithKeyValue(key, ">=", value)

        case .LessThan(let key, let value):
            return statementWithKeyValue(key, "<", value)

        case .LessThanOrEquals(let key, let value):
            return statementWithKeyValue(key, "<=", value)


        case .In(let key, let values):
            
            var strings = [String]()
            
            for _ in values {
                strings.append(Statement.parameterPlaceholder)
            }

            return Statement("\(key) IN(\(strings.joinWithSeparator(", ")))", parameters: values)

        case .NotIn(let key, let values):
            return (!Condition.In(key, values)).statement

        case .And(let conditions):
            return Statement(substatements: conditions.map { $0.statement }, mergedByString: "AND").isolate()

        case .Or(let conditions):
            return Statement(substatements: conditions.map { $0.statement }, mergedByString: "OR").isolate()

        case .Not(let condition):
            var statement = condition.statement.isolate()
            statement.prependComponent("NOT")
            return statement
        }
    }
}

public prefix func ! (condition: Condition) -> Condition {
    return .Not(condition)
}

public func && (lhs: Condition, rhs: Condition) -> Condition {
    return .And([lhs, rhs])
}

public func || (lhs: Condition, rhs: Condition) -> Condition {
    return .Or([lhs, rhs])
}