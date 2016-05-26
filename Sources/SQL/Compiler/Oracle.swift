






//public class OracleCompiler: Compiler {
//    override func offsetLimit(selectQuery: [String], offset: QueryComponent?, limit: QueryComponent?) -> [String] {
//
//
//        var stringParts = ["SELECT * FROM ( SELECT ROWNUM rnum, selectQuery.* FROM ("]
//        stringParts.append(contentsOf: selectQuery)
//        stringParts.append(") selectQuery")
//        stringParts.append("WHERE")
//        var offsetNumber: Int? = nil
//        if case let .offset(num)? = offset {
//            offsetNumber = num
//        }
//        if case let .limit(num)? = limit {
//            stringParts.append("WHERE ROWNUM <= \((offsetNumber ?? 0) + num)")
//        }
//        stringParts.append(")")
//        if let offsetNumber = offsetNumber {
//            stringParts.append("WHERE rnum >= \(offsetNumber)")
//        }
//        return stringParts
//    }
//}