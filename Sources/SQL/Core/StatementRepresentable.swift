// StatementRepresentable.swift
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


public protocol StatementStringRepresentable: CustomStringConvertible {
    var sqlString: String { get }
}

extension StatementStringRepresentable {
    public var description: String {
        return sqlString
    }
}

public extension String {
    public func sqlStringWithEscapedPlaceholdersUsingPrefix(_ prefix: String, suffix: String? = nil, transformer: (Int) -> String) -> String {
        
        var strings = split(byString: "%@")
        
        if strings.count == 1 {
            return self
        }
        
        var newStrings = [String]()
        
        for i in 0..<strings.count - 1 {
            newStrings.append(strings[i])
            newStrings.append(prefix)
            newStrings.append(transformer(i))
            
            if let suffix = suffix {
                newStrings.append(suffix)
            }
        }
        
        newStrings.append(strings.last!)
        
        return newStrings.joined(separator: "")
    }
}


public protocol StatementParameterListConvertible {
    var sqlParameters: [Value?] { get }
}

public extension Sequence where Iterator.Element: StatementStringRepresentable {
    public func sqlStringJoined(separator: String? = nil, isolate: Bool = false) -> String {
        return map { $0 as StatementStringRepresentable }.sqlStringJoined(separator: separator, isolate: isolate)
    }
}

public extension Sequence where Iterator.Element == StatementStringRepresentable {
    public func sqlStringJoined(separator: String? = nil, isolate: Bool = false) -> String {
        let string = map { $0.sqlString }.joined(separator: separator ?? "")
        
        if(isolate) {
            return "(\(string))"
        }
        
        return string
    }
}

public extension Sequence where Iterator.Element: StatementParameterListConvertible {
    public var sqlParameters: [Value?] {
        return map { $0 as StatementParameterListConvertible }.sqlParameters
    }
}

public extension Sequence where Iterator.Element == StatementParameterListConvertible {
    public var sqlParameters: [Value?] {
        return flatMap { $0.sqlParameters }
    }
}
