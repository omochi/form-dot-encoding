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

    var isEmpty: Bool {
        guard value == nil else { return false }
        guard array.allSatisfy({ $0 == nil }) else { return false }
        guard object.isEmpty else { return false }
        return true
    }

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
        if isEmpty {
            if path.count >= 1 {
                result.append(.init(path: path, value: "_"))
            }
            return
        }

        if let value {
            result.append(.init(path: path, value: value))
        }
        for (index, element) in array.enumerated() {
            if let element {
                element.query(path: path + [index.description], result: &result)
            }
        }
        for (key, element) in object.sorted(by: { $0.key < $1.key }) {
            element.query(path: path + [key], result: &result)
        }
    }

    convenience init(query: URLQuery) {
        self.init()

        self.loadQuery(query)
    }

    func loadQuery(_ query: URLQuery) {
        for element in query {
            if let value = element.value {
                loadQueryElement(path: element.path[...], value: value)
            }
        }
    }

    func loadQueryElement(path: ArraySlice<String>, value: String) {
        guard let key = path.first else {
            self.value = value
            return
        }

        var path = path
        path.removeFirst()

        if let index = Int(key) {
            let node = assumeIndex(index)
            node.loadQueryElement(path: path, value: value)
        } else {
            let node = assumeKey(key)
            node.loadQueryElement(path: path, value: value)
        }
    }
}
