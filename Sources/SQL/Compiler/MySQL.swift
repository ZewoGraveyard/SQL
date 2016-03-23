






public class MysqlCompiler: Compiler {
    override func offsetLimit(selectQuery: [String], offset: QueryComponent?, limit: QueryComponent?,
                              orderBy: QueryComponent?) -> [String] {

        var stringParts = selectQuery
        if case let .limit(num)? = limit {
            stringParts.append("LIMIT \(num)")
        }
        if case let .offset(num)? = offset {
            stringParts.append("OFFSET \(num)")
        }
        return stringParts
    }

}