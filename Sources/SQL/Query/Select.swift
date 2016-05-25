//
//  Select.swift
//  SQL
//
//  Created by David Ask on 23/05/16.
//
//

public class Select {
    public enum Top {
        case number(Int)
        case percent(Int)
    }
    
    var top: Top? = nil
    
    var order: [Order]? = nil
    
    public var fields: [SQLStringRepresentable]
    public let from: [SQLStringRepresentable]
    
    public var limit: Int? = nil
    public var offset: Int? = nil
    
    public var predicate: Predicate? = nil
    
    public var joins: [Join] = []
    
    // Default initializers
    
    public init(_ fields: [SQLStringRepresentable], from source: [SQLStringRepresentable]) {
        self.fields = fields
        self.from = source
    }
    
    // SELECT TOP initializers
    
    public init(top: Top, _ fields: [SQLStringRepresentable], from source: [SQLStringRepresentable]) {
        self.top = top
        self.fields = fields
        self.from = source
    }
    
    public func filter(_ predicate: Predicate) -> Select {
        self.predicate = predicate
        return self
    }
    
    public func extend(_ fields: SQLStringRepresentable...) -> Select {
        self.fields += fields
        return self
    }
    
    public func order(_ value: Order...) -> Select {
        var new = self.order ?? []
        new += value
        self.order = new
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

extension Select.Top: SQLStringRepresentable {
    public var sqlString: String {
        switch self {
        case .number(let num):
            return "TOP \(num)"
        case .percent(let percent):
            return "TOP \(percent)%"
        }
    }
}

extension Select: SQLStringRepresentable {
    public var sqlString: String {
        
        var components = [SQLStringRepresentable]()
        
        components.append("SELECT")
        
        if let top = top {
            components.append(top)
        }
        
        components.append(fields.sqlStringJoined(separator: ", "))
        components.append("FROM")
        components.append(from.sqlStringJoined(separator: ", "))
        components.append(joins.sqlStringJoined(separator: " "))
        components.append("WHERE")
    
        if let predicate = predicate {
            components.append(predicate)
        }
        
        if let order = order {
            components.append(order.sqlStringJoined(separator: ", "))
        }
        
        if let limit = limit {
            components.append("LIMIT \(limit)")
        }
        
        if let offset = offset {
            components.append("LIMIT \(offset)")
        }
        
        return components.sqlStringJoined(separator: " ", isolate: true)
    }
    
    public var sqlParameters: [Value?] {
        var parameters = [Value?]()
        
        parameters += fields.flatMap { $0.sqlParameters }
        parameters += from.flatMap { $0.sqlParameters }
        parameters += joins.flatMap { $0.sqlParameters }
        
        if let predicate = predicate {
            parameters += predicate.sqlParameters
        }
        
        return parameters
    }
}