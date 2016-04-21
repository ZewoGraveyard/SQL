// QueryComponents.swift
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


public struct QueryComponents: CustomStringConvertible {
    
    internal static let valuePlaceholder = "%@"
    
    public struct Error: ErrorProtocol {
        public let description: String
    }
    
    public var stringComponents: [String]
    public var values: [SQLData?]

    public var string: String {
        return stringComponents.filter { !$0.isEmpty }.map { $0.trim() }.joined(separator: " ")
    }
    
    public func stringWithEscapedValuesUsingPrefix(_ prefix: String, suffix: String? = nil, transformer: (Int, SQLData?) -> String) throws -> String {
        
        var strings = string.split(byString: QueryComponents.valuePlaceholder)
        
        if strings.count == 1 {
            return string
        }
        
        guard strings.count == values.count + 1 else {
            throw Error(description: "Parameter count mismatch")
        }
        
        var newStrings = [String]()
        
        for i in 0..<values.count {
            newStrings.append(strings[i])
            newStrings.append(prefix)
            newStrings.append(transformer(i, values[i]))
            
            if let suffix = suffix {
                newStrings.append(suffix)
            }
        }
        
        newStrings.append(strings.last!)
        
        return newStrings.joined(separator: "")
    }

    public init() {
        stringComponents = []
        values = []
    }
    
    public init(components: [QueryComponents], mergedByString string: String? = nil) {
        var stringComponents = [String]()
        for (i, component) in components.enumerated() {
            stringComponents += component.stringComponents
            
            if i < components.count - 1, let mergeString = string {
                stringComponents.append(mergeString)
            }
        }
        
        self.stringComponents = stringComponents
        self.values = components.flatMap { $0.values }
        
    }
    
    public init(strings: [String], values: [SQLData?] = []) {
        self.stringComponents = strings
        self.values = values
    }
    
    public init(_ string: String, values: [SQLData?] = []) {
        self.init(strings: [string], values: values)
    }

    public func isolate() -> QueryComponents {
        return QueryComponents("(" + stringComponents.joined(separator: " ") + ")", values: values)
    }

    public mutating func append(_ component: QueryComponents) {
        stringComponents += component.stringComponents
        values += component.values
    }
    
    public mutating func prepend(_ component: QueryComponents) {
        stringComponents = component.stringComponents + stringComponents
        values = component.values + values
    }
    
    public var description: String {
        guard let result = (try? stringWithEscapedValuesUsingPrefix("'", suffix: "'") {
            index, value in
        
            guard let value = value else {
                return "NULL"
            }
            
            switch value {
            case .Text(let string):
                return string
            default:
                return "BINARY DATA"
            }
        
        }) else {
            return string
        }
        
        return result
    }
}

extension QueryComponents: StringLiteralConvertible {
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

public protocol QueryComponentsConvertible {
    var queryComponents: QueryComponents { get }
}

public extension Sequence where Iterator.Element: QueryComponentsConvertible {
    public func queryComponents(mergedByString string: String? = nil) -> QueryComponents {
        return QueryComponents(components: self.map { $0.queryComponents }, mergedByString: string)
    }
    
    public var queryComponents: QueryComponents {
        return queryComponents()
    }
}