enum _CodingKey: CodingKey {
    case int(Int)
    case string(String)

    init?(stringValue: String) {
        self = .string(stringValue)
    }

    init?(intValue: Int) {
        self = .int(intValue)
    }

    var stringValue: String {
        switch self {
        case .int(let x): return x.description
        case .string(let x): return x
        }
    }

    var intValue: Int? {
        switch self {
        case .int(let x): return x
        case .string(let x): return Int(x)
        }
    }

    static let `super`: _CodingKey = .string("super")
}
