//
//  Select.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//

public protocol SelectReference {
    var selectReference: Select.Reference { get }
}

extension String: SelectReference {
    public var selectReference: Select.Reference {
        return .string(self)
    }
}

public class Select: PredicatedQuery {
    public enum Reference {
        case string(SQLStringRepresentable)
        case subquery(Select, alias: SQLStringRepresentable)
    }
    
    public var order: [Order] = []
    
    public var fields: [Reference]
    public let from: [Reference]
    
    public var limit: Int? = nil
    public var offset: Int? = nil
    
    public var predicate: Predicate? = nil
    
    public var joins: [Join] = []
    
    // Default initializers
    
    public func subqueryNamed(_ alias: SQLStringRepresentable) -> Reference {
        return .subquery(self, alias: alias)
    }
    
    public init(_ fields: [SelectReference], from source: [SelectReference]) {
        self.fields = fields.map { $0.selectReference }
        self.from = source.map { $0.selectReference }
    }
    
    public convenience init(_ fields: SelectReference..., from source: SelectReference) {
        self.init(fields, from: [source])
    }

    
    public func extend(_ fields: SelectReference...) -> Select {
        self.fields += fields.map { $0.selectReference }
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
    
    public func join(_ joinType: Join.`Type`, on leftKey: SQLStringRepresentable, equals rightKey: SQLStringRepresentable) -> Select {
        
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

extension Select.Reference: SQLPrametersRepresentable {
    public var sqlParameters: [Value?] {
        switch self {
        case .string:
            return []
        case .subquery(let select, _):
            return select.sqlParameters
        }
    }
}

extension Select.Reference: SelectReference {
    public var selectReference: Select.Reference {
        return self
    }
}


extension Select: SQLPrametersRepresentable {
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