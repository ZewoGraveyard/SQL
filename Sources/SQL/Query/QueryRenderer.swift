// QueryRenderer.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2016 Formbound
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

public protocol QueryRendererProtocol {
    
    static func renderStatement(_ statement: Select) -> String
    
    static func renderStatement(_ statement: Update) -> String
    
    static func renderStatement(_ statement: Insert, forReturningInsertedRows returnInsertedRows: Bool) -> String
    
    static func renderStatement(_ statement: Delete) -> String
}

public extension QueryRendererProtocol {
    static func composePredicate(_ predicate: Predicate) -> String {
        switch predicate {
        case .expression(let left, let op, let right):
            var components = [composeParameter(left), op.sqlString]
            
            switch op {
            case .containedIn, .contains:
                components.append("(\(composeParameter(right)))")
                break
            default:
                components.append(composeParameter(right))
            }
            
            return components.joined(separator: " ")
            
        case .and(let predicates):
            return "(\(predicates.map { composePredicate($0) }.joined(separator: " AND ")))"
        case .or(let predicates):
            return "(\(predicates.map { composePredicate($0) }.joined(separator: " OR ")))"
        case .not(let predicate):
            return "NOT \(composePredicate(predicate))"
        }
    }
    
    static func composeParameter(_ parameter: Parameter) -> String {
        switch parameter {
        case .field(let field):
            return field.qualifiedName
        case .function(let function):
            return function.sqlString
        case .query(let select):
            return "\(renderStatement(select))"
        case .value:
            return "%@"
        case .null:
            return "%@"
        case .values(let values):
            return values.map { _ in "%@" }.joined(separator: ", ")
        }
    }
}
