import Collections

final class ValueTree {
    init(
        value: String? = nil,
        array: [ValueTree?] = [],
        object: [String: ValueTree] = [:]
    ) {
        self.value = value
        self.array = array
        self.object = object
    }

    var value: String?
    var array: [ValueTree?]
    var object: [String: ValueTree]

    subscript(index index: Int) -> ValueTree? {
        get {
            guard 0 <= index, index < array.count else { return nil }
            return array[index]
        }
        set {
            while array.count <= index {
                array.append(nil)
            }
            array[index] = newValue
        }
    }

    private func assumeIndex(_ index: Int) -> ValueTree {
        if let node = self[index: index] { return node }
        let node = ValueTree()
        self[index: index] = node
        return node
    }

    subscript(key key: String) -> ValueTree? {
        get {
            object[key]
        }
        set {
            object[key] = newValue
        }
    }

    private func assumeKey(_ key: String) -> ValueTree {
        if let node = self[key: key] { return node }
        let node = ValueTree()
        self[key: key] = node
        return node
    }

    func query(path: URLQueryElement.Path = []) -> URLQuery {
        var result = URLQuery()
        query(path: path, result: &result)
        return result
    }

    private func query(path: URLQueryElement.Path, result: inout URLQuery) {
        if let value {
            result.append(.init(path: path, value: value))
        }
        for (index, element) in array.enumerated() {
            if let element {
                query(path: path + [index.description], result: &result)
            }
        }
        let keys = object.keys.sorted()
        for key in keys {
            query(path: path + [key], result: &result)
        }
    }

    func setQuery(_ query: URLQuery) {
        for element in query {
            if let value = element.value {
                setQueryElement(path: element.path[...], value: value)
            }
        }
    }

    func setQueryElement(path: ArraySlice<String>, value: String) {
        guard let key = path.first else {
            self.value = value
            return
        }

        var path = path
        path.removeFirst()

        if let index = Int(key) {
            let node = assumeIndex(index)
            node.setQueryElement(path: path, value: value)
        } else {
            let node = assumeKey(key)
            node.setQueryElement(path: path, value: value)
        }
    }
}
