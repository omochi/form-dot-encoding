import Testing
import Foundation
@testable import WebformDotEncoding

@Suite struct ValueTreeTests {

    @Test(arguments: [
        (ValueTree(value: "x"), URLQuery([.init(path: [], value: "x")]))
    ]) func query(tree: ValueTree, query: URLQuery) throws {

    }
}
