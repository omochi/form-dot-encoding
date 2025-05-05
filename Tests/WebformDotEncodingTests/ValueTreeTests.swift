import Testing
import Foundation
@testable import WebformDotEncoding

@Suite struct ValueTreeTests {
    @Test(arguments: [
        URLQuery(.init(path: [], value: "x")),
        URLQuery(.init(path: ["a"], value: "x")),
        URLQuery(.init(path: ["a"], value: "x"), .init(path: ["b"], value: "y")),
        URLQuery(.init(path: ["0"], value: "x")),
        URLQuery(.init(path: ["a", "b"], value: "x")),
        URLQuery(.init(path: ["a", "0"], value: "x")),
        URLQuery(.init(path: ["0"], value: "x"), .init(path: ["1"], value: "y")),
        URLQuery(.init(path: ["2"], value: "x")),
        URLQuery(.init(path: ["0", "a"], value: "x")),
        URLQuery(.init(path: ["2", "2", "a"], value: "x"), .init(path: ["2", "2", "b"], value: "x")),
    ]) func valueTree(query: URLQuery) throws {
        let tree = ValueTree(query: query)
        let encoded = tree.query()
        #expect(encoded == query)
    }
}
