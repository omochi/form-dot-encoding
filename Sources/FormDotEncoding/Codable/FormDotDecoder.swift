public struct FormDotDecoder {
    public init() {
        self.userInfo = [:]
    }

    public var userInfo: [CodingUserInfoKey: Any]

    public func decode<T: Decodable>(
        _ type: T.Type, from string: String,
        file: StaticString = #file, line: UInt = #line
    ) throws -> T {
        let query: URLQuery
        do {
            query = try URLQuery.parse(percentEncodedString: string, file: file, line: line)
        } catch {
            let x = DecodingError.Context(
                codingPath: [],
                debugDescription: "failed to parse query string: \(string)",
                underlyingError: error
            )
            throw DecodingError.dataCorrupted(x)
        }
        return try decodeFromQuery(type, from: query)
    }

    public func decodeFromQuery<T: Decodable>(_ type: T.Type, from query: URLQuery) throws -> T {
        let tree = ValueTree(query: query)
        let decoder = _Decoder(tree: tree, codingPath: [], userInfo: userInfo)
        return try type.init(from: decoder)
    }

    struct _Decoder: Decoder {
        let tree: ValueTree
        let codingPath: [any CodingKey]
        let userInfo: [CodingUserInfoKey: Any]

        func singleValueContainer() -> any SingleValueDecodingContainer {
            SC(decoder: self)
        }

        func unkeyedContainer() -> any UnkeyedDecodingContainer {
            UC(decoder: self)
        }

        func container<Key>(keyedBy type: Key.Type) -> KeyedDecodingContainer<Key> where Key : CodingKey {
            KeyedDecodingContainer(KC(decoder: self))
        }
    }

    struct SC: SingleValueDecodingContainer {
        let decoder: _Decoder

        var codingPath: [any CodingKey] { decoder.codingPath }

        func decodeNil() -> Bool {
            switch decoder.tree.value {
            case .null: return true
            default: return false
            }
        }

        func decode<T: Primitive>(_ type: T.Type) throws -> T {
            guard let string = decoder.tree.string else {
                let x = DecodingError.Context(
                    codingPath: codingPath, debugDescription: "no value"
                )
                throw DecodingError.valueNotFound(type, x)
            }

            guard let value = type.init(string) else {
                throw DecodingError.dataCorruptedError(
                    in: self,
                    debugDescription: """
                        failed to decode \(type) from string: "\(string)"
                        """
                )
            }

            return value
        }

        func decode<T: Decodable>(_ type: T.Type) throws -> T {
            try type.init(from: decoder)
        }
    }

    struct UC: UnkeyedDecodingContainer {
        let decoder: _Decoder

        var codingPath: [any CodingKey] { decoder.codingPath }

        var count: Int? { decoder.tree.array?.count ?? 0 }

        var isAtEnd: Bool { currentIndex == count }

        var currentIndex: Int = 0

        mutating func nested() -> _Decoder {
            let decoder = _Decoder(
                tree: decoder.tree.array?[currentIndex] ?? ValueTree(),
                codingPath: codingPath + [_CodingKey.int(currentIndex)],
                userInfo: decoder.userInfo
            )

            if !isAtEnd {
                currentIndex += 1
            }

            return decoder
        }

        mutating func superDecoder() -> any Decoder {
            nested()
        }

        mutating func nestedUnkeyedContainer() -> any UnkeyedDecodingContainer {
            nested().unkeyedContainer()
        }

        mutating func nestedContainer<NestedKey: CodingKey>(
            keyedBy type: NestedKey.Type
        ) -> KeyedDecodingContainer<NestedKey> {
            nested().container(keyedBy: type)
        }

        mutating func decodeNil() -> Bool {
            SC(decoder: nested()).decodeNil()
        }

        mutating func decode<T: Primitive>(_ type: T.Type) throws -> T {
            try SC(decoder: nested()).decode(type)
        }

        mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
            try SC(decoder: nested()).decode(type)
        }
    }

    struct KC<Key: CodingKey>: KeyedDecodingContainerProtocol {
        let decoder: _Decoder

        var codingPath: [any CodingKey] { decoder.codingPath }

        var allKeys: [Key] {
            decoder.tree.object?.keys.sorted().compactMap(Key.init) ?? []
        }

        func contains(_ key: Key) -> Bool {
            decoder.tree.object?[key.stringValue] != nil
        }

        private func nested(key: some CodingKey) -> _Decoder {
            _Decoder(
                tree: decoder.tree.object?[key.stringValue] ?? ValueTree(),
                codingPath: codingPath + [key],
                userInfo: decoder.userInfo
            )
        }

        func superDecoder() -> any Decoder {
            nested(key: _CodingKey.super)
        }

        func superDecoder(forKey key: Key) -> any Decoder {
            nested(key: key)
        }

        func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedDecodingContainer {
            nested(key: key).unkeyedContainer()
        }

        func nestedContainer<NestedKey: CodingKey>(
            keyedBy type: NestedKey.Type, forKey key: Key
        ) -> KeyedDecodingContainer<NestedKey> {
            nested(key: key).container(keyedBy: type)
        }

        func decodeNil(forKey key: Key) -> Bool {
            SC(decoder: nested(key: key)).decodeNil()
        }

        func decode<T: Primitive>(_ type: T.Type, forKey key: Key) throws -> T {
            try SC(decoder: nested(key: key)).decode(type)
        }

        func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
            try SC(decoder: nested(key: key)).decode(type)
        }
    }
}
