// Statement.swift
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

public struct Statement {
    public var stringComponents: [String]
    public var parameters: [ValueConvertible?]

    public var string: String {
        return stringComponents.filter { !$0.isEmpty }.joinWithSeparator(" ")
    }

    public init() {
        stringComponents = []
        parameters = []
    }

    public init(string: String, parameters: [ValueConvertible?] = []) {
        stringComponents = [string]
        self.parameters = parameters
    }

    public init(components: [String], parameters: [ValueConvertible?] = []) {
        self.stringComponents = components
        self.parameters = parameters
    }

    public func isolate() -> Statement {
        return Statement(components: ["(\(stringComponents.joinWithSeparator(" ")))"], parameters: parameters)
    }

    public mutating func prependComponent(string: String) {
        stringComponents.insert(string, atIndex: 0)
    }

    public mutating func appendComponent(string: String)  {
        stringComponents.append(string)
    }

    public mutating func merge(otherStatement: Statement, joinBy joinString: String? = nil) {

        if let joinString = joinString where !joinString.isEmpty {
            stringComponents.append(joinString)
        }

        stringComponents += otherStatement.stringComponents
    }

}

public protocol StatementConvertible {
    func statementWithParameterOffset(inout parameterOffset: Int) -> Statement
}

public extension StatementConvertible {
    public var statement: Statement {
        var offset = 1
        return statementWithParameterOffset(&offset)
    }
}


public extension SequenceType where Generator.Element: StatementConvertible {
    public func statementWithParameterOffset(inout parameterOffset: Int, joinBy joinString: String? = nil) -> Statement {

        var statement = Statement()

        for convertible in self {
            statement.merge(convertible.statementWithParameterOffset(&parameterOffset), joinBy: joinString)
        }

        return statement
    }
}