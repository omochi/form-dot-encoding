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
        return encoder.tree.query()
    }

    struct _Encoder: Encoder {
        init(tree: ValueTree, codingPath: [any CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.tree = ValueTree()
        }

        let tree: ValueTree
        let codingPath: [any CodingKey]
        let userInfo: [CodingUserInfoKey: Any]

        func singleValueContainer() -> any SingleValueEncodingContainer {
            SVC(encoder: self)
        }

        func unkeyedContainer() -> any UnkeyedEncodingContainer {
            UC(encoder: self)
        }

        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            <#code#>
        }
    }

    struct SVC: SingleValueEncodingContainer {
        let encoder: _Encoder
        
        var codingPath: [any CodingKey] { encoder.codingPath }

        func encodeNil() throws {}

        func encode(_ value: some Primitive) throws {
            encoder.tree.value = value.description
        }

        func encode(_ value: some Encodable) throws {
            try value.encode(to: encoder)
        }

        func encode(_ value: some Primitive & Encodable) throws {
            encoder.tree.value = value.description
        }
    }

    struct UC: UnkeyedEncodingContainer {
        let encoder: _Encoder

        var codingPath: [any CodingKey] { encoder.codingPath }

        var count: Int { encoder.tree.array.count }

        func encodeNil() throws {
            encoder.tree.array.append(nil)
        }

        private func nested() -> _Encoder {
            let nested = _Encoder(
                tree: ValueTree(),
                codingPath: codingPath + [IntCodingKey(intValue: count)],
                userInfo: encoder.userInfo
            )
            encoder.tree.array.append(nested.tree)
            return nested
        }

        func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
            nested().container(keyedBy: keyType)
        }

        func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
            nested().unkeyedContainer()
        }

        func superEncoder() -> any Encoder {
            nested()
        }

        func encode(_ value: some Primitive) throws {
            try SVC(encoder: nested()).encode(value)
        }

        func encode(_ value: some Encodable) throws {
            try SVC(encoder: nested()).encode(value)
        }

        func encode(_ value: some Primitive & Encodable) throws {
            try SVC(encoder: nested()).encode(value)
        }
    }
}
