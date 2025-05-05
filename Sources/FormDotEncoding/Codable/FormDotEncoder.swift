public struct FormDotEncoder {
    public init() {
        self.userInfo = [:]
    }

    public var userInfo: [CodingUserInfoKey: Any]

    public func encode(_ value: some Encodable) throws -> String {
        let query = try encodeToQuery(value)
        return query.description
    }

    public func encodeToQuery(_ value: some Encodable) throws -> URLQuery {
        let encoder = _Encoder(
            tree: ValueTree(), codingPath: [], userInfo: userInfo
        )
        try value.encode(to: encoder)
        _ = encoder.tree.preserveEmptyObject()
        return encoder.tree.query()
    }

    struct _Encoder: Encoder {
        let tree: ValueTree
        let codingPath: [any CodingKey]
        let userInfo: [CodingUserInfoKey: Any]

        func singleValueContainer() -> any SingleValueEncodingContainer {
            SC(encoder: self)
        }

        func unkeyedContainer() -> any UnkeyedEncodingContainer {
            UC(encoder: self)
        }

        func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
            KeyedEncodingContainer(KC<Key>(encoder: self))
        }
    }

    struct SC: SingleValueEncodingContainer {
        let encoder: _Encoder

        var codingPath: [any CodingKey] { encoder.codingPath }

        func encodeNil() {

        }

        func encode(_ value: some Primitive) {
            encoder.tree.string = value.description
        }

        func encode(_ value: some Encodable) throws {
            try value.encode(to: encoder)
        }
    }

    struct UC: UnkeyedEncodingContainer {
        init(encoder: _Encoder) {
            self.encoder = encoder
            _ = encoder.tree.assumeArray()
        }

        let encoder: _Encoder

        var codingPath: [any CodingKey] { encoder.codingPath }

        var count: Int { encoder.tree.array?.count ?? 0 }

        private func nested() -> _Encoder {
            let nested = _Encoder(
                tree: ValueTree(),
                codingPath: codingPath + [_CodingKey.int(count)],
                userInfo: encoder.userInfo
            )
            var array = encoder.tree.assumeArray()
            array.append(nested.tree)
            encoder.tree.array = array
            return nested
        }

        func superEncoder() -> any Encoder {
            nested()
        }

        func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
            nested().unkeyedContainer()
        }

        func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
            nested().container(keyedBy: keyType)
        }

        func encodeNil() {
            SC(encoder: nested()).encodeNil()
        }

        func encode(_ value: some Primitive) {
            SC(encoder: nested()).encode(value)
        }

        func encode(_ value: some Encodable) throws {
            try SC(encoder: nested()).encode(value)
        }
    }

    struct KC<Key: CodingKey>: KeyedEncodingContainerProtocol {
        init(encoder: _Encoder) {
            self.encoder = encoder
            _ = encoder.tree.assumeObject()
        }

        let encoder: _Encoder

        var codingPath: [any CodingKey] { encoder.codingPath }

        private func nested(key: some CodingKey) -> _Encoder {
            let nested = _Encoder(
                tree: ValueTree(),
                codingPath: codingPath + [key],
                userInfo: encoder.userInfo
            )
            var object = encoder.tree.assumeObject()
            object[key.stringValue] = nested.tree
            encoder.tree.object = object
            return nested
        }

        func superEncoder() -> any Encoder {
            nested(key: _CodingKey.super)
        }

        func superEncoder(forKey key: Key) -> any Encoder {
            nested(key: key)
        }

        func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
            nested(key: key).unkeyedContainer()
        }

        func nestedContainer<NestedKey: CodingKey>(
            keyedBy keyType: NestedKey.Type, forKey key: Key
        ) -> KeyedEncodingContainer<NestedKey> {
            nested(key: key).container(keyedBy: keyType)
        }

        func encodeNil(forKey key: Key) {
            SC(encoder: nested(key: key)).encodeNil()
        }

        func encode(_ value: some Primitive, forKey key: Key) {
            SC(encoder: nested(key: key)).encode(value)
        }

        func encode(_ value: some Encodable, forKey key: Key) throws {
            try SC(encoder: nested(key: key)).encode(value)
        }
    }
}
