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

    final class _Encoder: Encoder {
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

        }

        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            <#code#>
        }
    }

    struct SVC: SingleValueEncodingContainer {
        let encoder: _Encoder
        
        var codingPath: [any CodingKey] { encoder.codingPath }

        private func set(_ string: String) {
            encoder.tree.value = string
        }

        mutating func encodeNil() throws {}

        mutating func encode(_ value: String) throws {
            encoder.tree.value = value
        }

        mutating func encode(_ value: some Primitive) throws {
            try encode(value.description)
        }

        mutating func encode(_ value: some Primitive & Encodable) throws {
            try encode(value.description)
        }

        mutating func encode(_ value: some Encodable) throws {
            try value.encode(to: encoder)
        }
    }
}
