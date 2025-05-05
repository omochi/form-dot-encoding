import Testing
import FormDotEncoding

@Suite struct EncoderTests {
    struct S: Codable & Equatable {
        var a: Int?
        var k: K?
        var v: [K]?
        var w: [K?]?
    }

    struct K: Codable & Equatable {
        var a: Int?
    }

    enum E: Codable & Equatable {
        case a
        case b(K?)
    }

    typealias X = any Sendable & Equatable & Codable

    @Test(arguments: [
        (S(a: 1), "a=1"),
        (S(), ""),
        (S(k: K(a: 1)), "k.a=1"),
        (S(k: K()), "k=_"),
        (S(v: []), "v=_"),
        (S(v: [K()]), "v.0=_"),
        (S(v: [K(a: 1)]), "v.0.a=1"),
        (S(v: [K(a: 1), K(), K(a: 2)]), "v.0.a=1&v.1=_&v.2.a=2"),
        (S(w: []), "w=_"),
        (S(w: [K()]), "w.0=_"),
        (S(w: [nil, K()]), "w.1=_"),
        (S(w: [nil, K(a: 1)]), "w.1.a=1"),
        (E.a, "a=_"),
        (E.b(K(a: 1)), "b._0.a=1"),
        (E.b(K()), "b._0=_"),
    ] as [(X, String)])
    func encodeRoundtrip(value: X, string: String) throws {
        try encodeRoundtrip1(value: value, string: string)
    }

    private func encodeRoundtrip1<T: Codable & Equatable>(value: T, string: String) throws {
        let encoder = FormDotEncoder()
        let encoded = try encoder.encode(value)
        #expect(encoded == string)

        let decoder = FormDotDecoder()
        let decoded = try decoder.decode(T.self, from: encoded)
        #expect(decoded == value)
    }

    @Test(arguments: [
        (S(w: [nil]), S(w: [])),
        (S(w: [K(), nil]), S(w: [K()])),
    ] as [(X, X)])
    func encodeNonRoundtrip(value: X, expected: X) throws {
        try encodeNonRoundtrip1(value: value, expected: expected)
    }

    private func encodeNonRoundtrip1<T: Codable & Equatable>(value: T, expected: X) throws {
        try encodeNonRoundtrip2(value: value, expected: expected as! T)
    }

    private func encodeNonRoundtrip2<T: Codable & Equatable>(value: T, expected: T) throws {
        let encoder = FormDotEncoder()
        let encoded = try encoder.encode(value)
        let decoder = FormDotDecoder()
        let decoded = try decoder.decode(T.self, from: encoded)
        #expect(decoded == expected)
    }
}
