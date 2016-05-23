
public struct ColumnProperty: QueryComponentRepresentable {
    let parts: [QueryComponent]

    public var queryComponent: QueryComponent {
        return .parts(parts)
    }
    public init(_ parts: [QueryComponent]) {
        self.parts = parts
    }
}

extension ColumnProperty: SQLDataRepresentable {
    public var sqlData: SQLData {
        return .Query(self.queryComponent)
    }

}

public func FunctionFactory(_ functionName: String) -> (QueryComponentRepresentable...) -> ColumnProperty {

    func function(args: QueryComponentRepresentable...) -> ColumnProperty {
        var parts: [QueryComponent] = [.sql(functionName), "("]
        let argsParts = args.map { [$0.queryComponent] }.joined(separator: [","])
        parts.append(contentsOf: argsParts)
        parts.append(")")
        return ColumnProperty(parts)
    }

    return function
}


public class Func {
    static let function = FunctionFactory
    static let count = FunctionFactory("count")
    static let max = FunctionFactory("max")
    static let min = FunctionFactory("min")
    static let abs = FunctionFactory("abs")
    static let mod = FunctionFactory("mod")
    static let floor = FunctionFactory("floor")
    static let sqrt = FunctionFactory("sqrt")
}