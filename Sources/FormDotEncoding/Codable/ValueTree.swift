import Collections

final class ValueTree {
    enum Value {
        case null
        case string(String)
        case array([ValueTree])
        case object([String: ValueTree])

        var string: String? {
            get {
                switch self {
                case .string(let x): return x
                default: return nil
                }
            }
            set {
                guard let newValue else { return }
                self = .string(newValue)
            }
        }

        var array: [ValueTree]? {
            get {
                switch self {
                case .array(let x): return x
                default: return nil
                }
            }
            set {
                guard let newValue else { return }
                self = .array(newValue)
            }
        }

        var object: [String: ValueTree]? {
            get {
                switch self {
                case .object(let x): return x
                default: return nil
                }
            }
            set {
                guard let newValue else { return }
                self = .object(newValue)
            }
        }
    }

    init(_ value: Value = .null) {
        self.value = value
    }

    var value: Value

    var string: String? {
        get { value.string }
        set { value.string = newValue }
    }

    var array: [ValueTree]? {
        get { value.array }
        set { value.array = newValue }
    }

    func assumeArray() -> [ValueTree] {
        if let array { return array }
        let array: [ValueTree] = []
        self.array = array
        return array
    }

    var object: [String: ValueTree]? {
        get { value.object }
        set { value.object = newValue }
    }

    func assumeObject() -> [String: ValueTree] {
        if let object { return object }
        let object: [String: ValueTree] = [:]
        self.object = object
        return object
    }

    func arrayElement(index: Int) -> ValueTree {
        precondition(0 <= index)
        var array = self.assumeArray()
        while array.count <= index {
            array.append(ValueTree())
        }
        self.array = array
        return array[index]
    }

    func objectElement(key: String) -> ValueTree {
        var object = self.assumeObject()
        if object[key] == nil {
            object[key] = ValueTree()
        }
        self.object = object
        return object[key]!
    }

    func query(path: URLQueryElement.Path = []) -> URLQuery {
        var result = URLQuery()
        query(path: path, result: &result)
        return result
    }

    private func query(path: URLQueryElement.Path, result: inout URLQuery) {
        switch value {
        case .null: return
        case .string(let x):
            result.append(.init(path: path, value: x))
        case .array(let x):
            for (index, element) in x.enumerated() {
                element.query(path: path + [index.description], result: &result)
            }
        case .object(let x):
            for (key, element) in x.sorted(by: { $0.key < $1.key }) {
                element.query(path: path + [key], result: &result)
            }
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
            self.string = value
            return
        }

        var path = path
        path.removeFirst()

        if let index = Int(key) {
            let node = self.arrayElement(index: index)
            node.loadQueryElement(path: path, value: value)
        } else {
            let node = self.objectElement(key: key)
            node.loadQueryElement(path: path, value: value)
        }
    }
}
