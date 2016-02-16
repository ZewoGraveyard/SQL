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
    public enum Value {
        case Value(ValueConvertible?)
        case Property(String)
    }

    case Equals(String, Value)

    case GreaterThan(String, Value)
    case GreaterThanOrEquals(String, Value)

    case LessThan(String, Value)
    case LessThanOrEquals(String, Value)


    case In(String, [ValueConvertible?])
    case NotIn(String, [ValueConvertible?])

    case And([Condition])
    case Or([Condition])

    case Not(Condition)


    public func statementWithParameterOffset(inout parameterOffset: Int) -> Statement {

        func statementWithKeyValue(key: String, _ op: String, _ value: Value) -> Statement {
            switch value {
            case .Value(let Value):
                let result = Statement(string: "\(key) \(op) $\(parameterOffset)", parameters: [Value])
                parameterOffset += 1
                return result
            case .Property(let name):
                return Statement(string: "\(key) \(op) \(name)", parameters: [])
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

            let parameterString = (parameterOffset..<parameterOffset + values.count).map {
                return "$\($0)"
            }.joinWithSeparator(", ")

            return Statement(string: "\(key) IN(\(parameterString))", parameters: values)

        case .NotIn(let key, let values):
            return (!Condition.In(key, values)).statementWithParameterOffset(&parameterOffset)

        case .And(let conditions):
            return conditions.statementWithParameterOffset(&parameterOffset, joinBy: "AND").isolate()

        case .Or(let conditions):
            return conditions.statementWithParameterOffset(&parameterOffset, joinBy: "OR").isolate()

        case .Not(let condition):
            var statement = condition.statementWithParameterOffset(&parameterOffset).isolate()
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