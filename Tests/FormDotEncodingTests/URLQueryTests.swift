import Testing
import Foundation
import FormDotEncoding

@Suite struct URLQueryTests {
    @Test(arguments: [
        (.init(path: ["a"], value: "x"), "a=x"),
        (.init(path: ["a"], value: ""), "a="),
        (.init(path: ["a"], value: nil), "a"),
        (.init(path: [], value: "x"), "=x"),
        (.init(path: ["あ"], value: "い"), "%E3%81%82=%E3%81%84"),
        (.init(path: ["a", "b", "c"], value: "x"), "a.b.c=x"),
        (.init(path: ["あ", "い"], value: "x"), "%E3%81%82.%E3%81%84=x"),
        (.init(path: ["_", "-"], value: "x"), "_.-=x"),
        (.init(path: ["%", "=", "&", "/"], value: "x"), "%25.%3D.%26.%2F=x"),
        (.init(path: ["a.b", "c.d"], value: "x"), "a%2Eb.c%2Ed=x"),
    ] as [(URLQueryElement, String)])
    func elementEncoding(element: URLQueryElement, expected: String) throws {
        let encoded = element.description
        #expect(encoded == expected)
        let decoded = try URLQueryElement.parse(percentEncodedString: encoded)
        #expect(decoded == element)

        let queryItemEncoded = element.percentEncodedQueryItem
        let queryItemDecoded = try URLQueryElement.parse(percentEncodedQueryItem: queryItemEncoded)
        #expect(queryItemDecoded == element)
    }

    @Test(arguments: [
        (
            URLQuery(
                .init(path: ["a"], value: "x"),
                .init(path: ["b"], value: "y")
            ), "a=x&b=y"
        )
    ] as [(URLQuery, String)])
    func queryEncoding(query: URLQuery, expected: String) throws {
        let encoded = query.description
        #expect(encoded == expected)
        let decoded = try URLQuery.parse(percentEncodedString: encoded)
        #expect(decoded == query)

        let queryItemsEncoded = query.percentEncodedQueryItems
        let queryItemsDecoded = try URLQuery.parse(percentEncodedQueryItems: queryItemsEncoded)
        #expect(queryItemsDecoded == query)
    }

    @Test func foundationURLQueryPercentEncoding() {
        let u = URL(string: "/p?a=あ")!
        #expect(u.query(percentEncoded: true) == "a=%E3%81%82")
        #expect(u.query(percentEncoded: false) == "a=あ")
        // default is encoded
        #expect(u.query == "a=%E3%81%82")
        #expect(u.query() == "a=%E3%81%82")
    }

    @Test func foundationURLComponentsQueryPercentEncoding() {
        let u = URLComponents(string: "/p?a=あ")!
        #expect(u.percentEncodedQuery == "a=%E3%81%82")
        #expect(u.percentEncodedQueryItems == [.init(name: "a", value: "%E3%81%82")])
        // default is decoded
        #expect(u.query == "a=あ")
        #expect(u.queryItems == [.init(name: "a", value: "あ")])
    }
}
