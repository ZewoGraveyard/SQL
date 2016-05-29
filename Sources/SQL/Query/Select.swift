//
//  Select.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//

public protocol SelectComponentConvertible {
    var sqlSelectComponent: Select.Component { get }
}

public class Select: PredicatedQuery {
    public enum Component {
        case field(QualifiedField)
        case string(String)
        case subquery(Select, alias: String)
        case function(Function, alias: String)
    }
    
    public var order: [Order] = []
    
    private(set) public var fields: [Component]
    public let from: [Component]
    
    private(set) public var limit: Int? = nil
    private(set) public var offset: Int? = nil
    
    public var predicate: Predicate? = nil
    
    public var joins: [Join] = []
    
    public func subquery(as alias: String) -> Component {
        return .subquery(self, alias: alias)
    }
    
    public init(_ fields: [SelectComponentConvertible], from source: [SelectComponentConvertible]) {
        self.fields = fields.map { $0.sqlSelectComponent }
        self.from = source.map { $0.sqlSelectComponent }
    }
    
    public convenience init(_ fields: SelectComponentConvertible..., from source: SelectComponentConvertible) {
        self.init(fields, from: [source])
    }
    
    public func extend(_ fields: SelectComponentConvertible...) -> Select {
        self.fields += fields.map { $0.sqlSelectComponent }
        return self
    }
    
    public func order(_ value: Order...) -> Select {
        order += value
        return self
    }
    
    public var first: Select {
        limit = 1
        offset = 0
        return self
    }
    
    public func limit(_ value: Int) -> Select {
        limit = value
        return self
    }
    
    public func offset(_ value: Int) -> Select {
        offset = value
        return self
    }
    
    public func join(_ joinType: Join.`Type`, on leftKey: QualifiedField, equals rightKey: QualifiedField) -> Select {
        
        joins.append(
            Join(
                type: joinType,
                leftKey: leftKey,
                rightKey: rightKey
            )
        )
        
        return self
    }
    
}

extension Select.Component: StatementParameterListConvertible {
    public var sqlParameters: [Value?] {
        switch self {
        case .string:
            return []
        case .subquery(let select, _):
            return select.sqlParameters
        case .field:
            return []
        case .function:
            return []
        }
    }
}

extension Select: ParameterConvertible {
    public var sqlParameter: Parameter {
        return .query(self)
    }
}

extension Select.Component: StringLiteralConvertible {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self = .string(value)
    }
}

extension Select.Component: SelectComponentConvertible {
    public var sqlSelectComponent: Select.Component {
        return self
    }
}

extension QualifiedField: SelectComponentConvertible {
    public var sqlSelectComponent: Select.Component {
        return .string(qualifiedName)
    }
}

extension String: SelectComponentConvertible {
    public var sqlSelectComponent: Select.Component {
        return .string(self)
    }
}


extension Select: StatementParameterListConvertible {
    public var sqlParameters: [Value?] {
        var parameters = [Value?]()
        
        parameters += fields.flatMap { $0.sqlParameters }
        parameters += from.flatMap { $0.sqlParameters }
        
        if let predicate = predicate {
            parameters += predicate.sqlParameters
        }
        
        return parameters
    }
}