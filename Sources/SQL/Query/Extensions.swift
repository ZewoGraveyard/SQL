








//
public struct Case: QueryComponentsRepresentable {
    private var aliasName: String = "defaultCase"
    let cases:  [(QueryComponentsRepresentable, QueryComponentsRepresentable)]
    let _else: QueryComponentsRepresentable
    public init(_ cases: [(QueryComponentsRepresentable, QueryComponentsRepresentable)], _else: QueryComponentsRepresentable) {
        self.cases = cases
        self._else = _else
    }
    public var queryComponents: QueryComponents {
        var components: [QueryComponentsRepresentable] = ["CASE"]
        for (condition, value) in cases {
            components.append("WHEN")
            components.append(condition)
            components.append("THEN")
            components.append(value)
        }
        components.append("ELSE")
        components.append(_else)
        components.append("END AS")
        components.append(aliasName)

        return QueryComponents(components: components.map{$0.queryComponents})
    }
    public func alias(newAlias: String) -> Case {
        var new = self
        new.aliasName = newAlias
        return new
    }
}