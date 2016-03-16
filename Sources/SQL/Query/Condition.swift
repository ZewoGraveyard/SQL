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

public indirect enum Condition: QueryComponentsConvertible {
    public enum Key {
        case Value(SQLData?)
        case Property(DeclaredField)
    }

    case Equals(DeclaredField, Key)

    case GreaterThan(DeclaredField, Key)
    case GreaterThanOrEquals(DeclaredField, Key)

    case LessThan(DeclaredField, Key)
    case LessThanOrEquals(DeclaredField, Key)

    
    case Like(DeclaredField, SQLData?)
    
    case In(DeclaredField, [SQLData?])
    case NotIn(DeclaredField, [SQLData?])

    case And([Condition])
    case Or([Condition])

    case Not(Condition)


    public var queryComponents: QueryComponents {

        func statementWithKeyValue(key: String, _ op: String, _ value: Key) -> QueryComponents {
            switch value {
            case .Value(let value):
                return QueryComponents("\(key) \(op) \(QueryComponents.valuePlaceholder)", values: [value])
            case .Property(let name):
                return QueryComponents("\(key) \(op) \(name)", values: [])
            }
        }

        switch self {
        case .Equals(let key, let value):
            return statementWithKeyValue(key.qualifiedName, "=", value)

        case .GreaterThan(let key, let value):
            return statementWithKeyValue(key.qualifiedName, ">", value)

        case .GreaterThanOrEquals(let key, let value):
            return statementWithKeyValue(key.qualifiedName, ">=", value)

        case .LessThan(let key, let value):
            return statementWithKeyValue(key.qualifiedName, "<", value)

        case .LessThanOrEquals(let key, let value):
            return statementWithKeyValue(key.qualifiedName, "<=", value)


        case .In(let key, let values):
            
            var strings = [String]()
            
            for _ in values {
                strings.append(QueryComponents.valuePlaceholder)
            }

            return QueryComponents("\(key) IN(\(strings.joined(separator: ", ")))", values: values)

        case .NotIn(let key, let values):
            return (!Condition.In(key, values)).queryComponents

        case .And(let conditions):
            return QueryComponents(components: conditions.map { $0.queryComponents }, mergedByString: "AND").isolate()

        case .Or(let conditions):
            return QueryComponents(components: conditions.map { $0.queryComponents }, mergedByString: "OR").isolate()

        case .Not(let condition):
            var queryComponents = condition.queryComponents.isolate()
            queryComponents.prepend("NOT")
            return queryComponents
            
        case .Like(let key, let value):
            return QueryComponents(strings: [key.qualifiedName, "LIKE", QueryComponents.valuePlaceholder], values: [value])
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
