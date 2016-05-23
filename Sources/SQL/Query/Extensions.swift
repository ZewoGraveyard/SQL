////
////
////
////
////
////
////
////
////
//////
//
//public struct Case: QueryComponentRepresentable {
//    private var aliasName: String = "defaultCase"
//    let cases:  OrderedDict<QueryComponentRepresentable, QueryComponentRepresentable>
//    let _else: QueryComponentRepresentable
//    public init(_ cases: OrderedDict<QueryComponentRepresentable, QueryComponentRepresentable>, _else: QueryComponentRepresentable) {
//        self.cases = cases
//        self._else = _else
//    }
//    public var queryComponent: queryComponent {
////        var components: [QueryComponentRepresentable] = ["CASE"]
////        for (condition, value) in cases {
////            components.append("WHEN")
////            components.append(condition)
////            components.append("THEN")
////            components.append(value)
////        }
////        components.append("ELSE")
////        components.append(_else)
////        components.append("END AS")
////        components.append(aliasName)
////
////        return queryComponent(components: components.map{$0.queryComponent})
//    }
//    public func alias(newAlias: String) -> Case {
//        var new = self
//        new.aliasName = newAlias
//        return new
//    }
//}