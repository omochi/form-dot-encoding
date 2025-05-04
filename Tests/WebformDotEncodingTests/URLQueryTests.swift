import Testing
import WebformDotEncoding

@Suite struct URLQueryTests {
    @Test(arguments: [
        (.init(path: ["a"], value: "x"), "a=x"),
        (.init(path: ["a"], value: ""), "a="),
        (.init(path: ["a"], value: nil), "a"),
        (.init(path: ["あ"], value: "い"), "%E3%81%82=%E3%81%84"),
        (.init(path: ["a", "b", "c"], value: "x"), "a.b.c=x"),
        (.init(path: ["あ", "い"], value: "x"), "%E3%81%82.%E3%81%84=x"),
    ] as [(URLQueryElement, String)])
    func testElementEncoding(element: URLQueryElement, expected: String) throws {
        let encoded = element.description
        #expect(encoded == expected)
        let decoded = try URLQueryElement.parse(string: encoded)
        #expect(decoded == element)
    }
}
