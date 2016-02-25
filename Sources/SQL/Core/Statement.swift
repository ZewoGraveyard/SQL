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


public struct Statement: CustomStringConvertible {
    
    internal static let parameterPlaceholder = "%@"
    
    public struct Error: ErrorType {
        public let description: String
    }
    
    public var stringComponents: [String]
    public var parameters: [Value?]

    public var string: String {
        return stringComponents.filter { !$0.isEmpty }.map { $0.trim() }.joinWithSeparator(" ")
    }
    
    public func stringWithNumberedParametersUsingPrefix(prefix: String, suffix: String? = nil) throws -> String {
        var strings = string.splitBy(Statement.parameterPlaceholder)
        
        if strings.count == 1 {
            return string
        }
        
        guard strings.count == parameters.count + 1 else {
            throw Error(description: "Parameter count mismatch")
        }
        
        var newStrings = [String]()
        
        for i in 0..<parameters.count {
            newStrings.append(strings[i])
            newStrings.append("\(prefix)\(i + 1)\(suffix ?? "")")
        }
        
        newStrings.append(strings.last!)

        return newStrings.joinWithSeparator("")
    }

    public init() {
        stringComponents = []
        parameters = []
    }
    
    public init(substatements: [Statement], mergedByString string: String? = nil) {
        var stringComponents = [String]()
        for (i, statement) in substatements.enumerate() {
            stringComponents += statement.stringComponents
            
            if i < substatements.count - 1, let mergeString = string {
                stringComponents.append(mergeString)
            }
        }
        
        self.stringComponents = stringComponents
        self.parameters = substatements.flatMap { $0.parameters }
    }
    
    public init(_ string: String, parameters: [Value?] = []) {
        self.stringComponents = [string]
        self.parameters = parameters
    }
    
    public init(components: [String], parameters: [Value?] = []) {
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
    
    public mutating func append(statement: Statement) {
        stringComponents += statement.stringComponents
        parameters += statement.parameters
    }
    
    public var description: String {
        return "<Statement string: \"\(string)\", parameters: \(parameters)"
    }
}

extension Statement: StringLiteralConvertible {
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

extension Statement: StringInterpolationConvertible {
    public init<T>(stringInterpolationSegment expr: T) {
        self.init("\(expr)")
    }
    
    public init<T: ValueConvertible>(stringInterpolationSegment expr: T) {
        self.init(Statement.parameterPlaceholder, parameters: [expr.SQLValue])
    }
    
    public init(stringInterpolationSegment expr: String) {
        self.init(expr)
    }
    
    public init(stringInterpolation strings: Statement...) {
        self.init(substatements: strings)
    }
}


public protocol StatementConvertible {
    var statement: Statement { get }
}