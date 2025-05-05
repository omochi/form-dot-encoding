import Testing
import FormDotEncoding

@Suite struct EncoderTests {
    struct S: Codable & Equatable {
        var a: Int?
        var k: K?
        var v: [K]?
        var w: [K?]
    }

    struct K: Codable & Equatable {
        var a: Int?
    }

    enum E: Codable & Equatable {
        case a
        case b(K?)
    }

    @Test(arguments: [
//        (S(a: 1), "a=1"),
//        (S(), ""),
//        (S(k: K(a: 1)), "k.a=1"),
//        (S(k: K()), "k=_"),
//        (S(v: []), "v=_"),
//        (S(v: [K()]), "v.0=_"),
//        (S(v: [K(a: 1)]), "v.0.a=1"),
//        (S(v: [K(a: 1), K(), K(a: 2)]), "v.0.a=1&v.1=_&v.2.a=2"),
        (S(w: [nil, nil, K()]), "w.0=_&w.1=_&w.2=_"),
//        (E.a, "a=_"),
//        (E.b(K(a: 1)), "b._0.a=1"),
//        (E.b(K()), "b._0=_"),
    ] as [(any Sendable & Equatable & Codable, String)])
    func encode(value: any Sendable & Equatable & Codable, string: String) throws {
        try encode(openingValue: value, string: string)
    }

    private func encode<T: Codable & Equatable>(openingValue value: T, string: String) throws {
        let encoder = FormDotEncoder()
        let encoded = try encoder.encode(value)
        #expect(encoded == string)

        let decoder = FormDotDecoder()
        let decoded = try decoder.decode(type(of: value).self, from: encoded)
        #expect(decoded == value)
    }
}
