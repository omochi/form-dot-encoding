import Testing
import FormDotEncoding

typealias SendableEncodable = Encodable & Sendable

@Suite struct EncoderTests {
    struct S: Codable {
        var a: Int?
        var k: K?
        var v: [K]?
    }

    struct K: Codable {
        var a: Int?
    }

    enum E: Codable {
        case a
        case b(K?)
    }

    @Test(arguments: [
        (S(a: 1), "a=1"),
        (S(), ""),
        (S(k: K(a: 1)), "k.a=1"),
        (S(k: K()), "k=_"),
        (S(v: []), "v=_"),
        (S(v: [K()]), "v.0=_"),
        (S(v: [K(a: 1)]), "v.0.a=1"),
        (S(v: [K(a: 1), K(), K(a: 2)]), "v.0.a=1&v.1=_&v.2.a=2"),
        (E.a, "a=_"),
        (E.b(K(a: 1)), "b._0.a=1"),
        (E.b(K()), "b._0=_"),
    ] as [(any SendableEncodable, String)]) func encode(value: any SendableEncodable, string: String) throws {
        let encoder = FormDotEncoder()
        let encoded = try encoder.encode(value)
        #expect(encoded == string)
    }
}
