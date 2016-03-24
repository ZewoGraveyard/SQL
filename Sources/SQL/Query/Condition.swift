//// Condition.swift
////
//// The MIT License (MIT)
////
//// Copyright (c) 2015 Formbound
////
//// Permission is hereby granted, free of charge, to any person obtaining a copy
//// of this software and associated documentation files (the "Software"), to deal
//// in the Software without restriction, including without limitation the rights
//// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//// copies of the Software, and to permit persons to whom the Software is
//// furnished to do so, subject to the following conditions:
////
//// The above copyright notice and this permission notice shall be included in all
//// copies or substantial portions of the Software.
////
//// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//// SOFTWARE.
//
public indirect enum Condition: QueryComponentRepresentable { //todo should be params or smth like
//    public enum Key {
//        case Value(SQLData?)
//        case Property(DeclaredField)
//    }

    case Equals(QueryComponentRepresentable, QueryComponentRepresentable)

    case GreaterThan(QueryComponentRepresentable, QueryComponentRepresentable)
    case GreaterThanOrEquals(QueryComponentRepresentable, QueryComponentRepresentable)

    case LessThan(QueryComponentRepresentable, QueryComponentRepresentable)
    case LessThanOrEquals(QueryComponentRepresentable, QueryComponentRepresentable)


    case Like(QueryComponentRepresentable, QueryComponentRepresentable)

    case In(QueryComponentRepresentable, [QueryComponentRepresentable])
    case NotIn(QueryComponentRepresentable, [QueryComponentRepresentable])

    case And([Condition])
    case Or([Condition])

    case Not(Condition)


    public var queryComponent: QueryComponent {
        return .condition(condition: self)
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


public func == (lhs: QueryComponentRepresentable, rhs: QueryComponentRepresentable) -> Condition {
    return .Equals(lhs, rhs)
}

public func != (lhs: QueryComponentRepresentable, rhs: QueryComponentRepresentable) -> Condition {
    return .Not(.Equals(lhs, rhs))
}
