public import Foundation

public struct URLQuery: Sendable & Hashable & CustomStringConvertible {
    public init() {
        elements = []
    }

    public init(_ elements: some Sequence<URLQueryElement>) {
        self.elements = Array(elements)
    }

    public init(_ elements: URLQueryElement...) {
        self.init(elements)
    }

    private var elements: [URLQueryElement]

    public var description: String {
        elements.map(\.description).joined(separator: "&")
    }

    public static func parse(
        percentEncodedString string: some StringProtocol,
        file: StaticString = #file, line: UInt = #line
    ) throws(BrokenPercentEncodingError) -> URLQuery {
        let elements = try string.split(separator: "&").map { (element) throws(BrokenPercentEncodingError) in
            try URLQueryElement.parse(percentEncodedString: element, file: file, line: line)
        }
        return URLQuery(elements)
    }

    public static func parse(
        percentEncodedQueryItems items: [URLQueryItem],
        file: StaticString = #file, line: UInt = #line
    ) throws(BrokenPercentEncodingError) -> URLQuery {
        let elements = try items.map { (item) throws(BrokenPercentEncodingError) in
            try URLQueryElement.parse(percentEncodedQueryItem: item, file: file, line: line)
        }
        return URLQuery(elements)
    }

    public var percentEncodedQueryItems: [URLQueryItem] {
        elements.map(\.percentEncodedQueryItem)
    }

    public mutating func set(_ element: URLQueryElement) {
        for (i, x) in enumerated() {
            if x.path == element.path {
                self[i] = element
                return
            }
        }

        append(element)
    }

    public mutating func set(path: URLQueryElement.Path, value: String?) {
        set(URLQueryElement(path: path, value: value))
    }

    public mutating func set(name: String, value: String?) {
        set(URLQueryElement(name: name, value: value))
    }

    public mutating func merge(_ query: some Sequence<URLQueryElement>) {
        for x in query {
            set(x)
        }
    }

    public func merging(_ query: some Sequence<URLQueryElement>) -> URLQuery {
        var result = self
        result.merge(query)
        return result
    }
}

extension URLQuery: RandomAccessCollection & MutableCollection {
    public typealias Index = Int

    public var startIndex: Int { elements.startIndex }
    public var endIndex: Int { elements.endIndex }

    public subscript(position: Int) -> URLQueryElement {
        _read {
            yield elements[position]
        }
        _modify {
            yield &elements[position]
        }
    }
}

extension URLQuery: RangeReplaceableCollection {
    public mutating func replaceSubrange(
        _ subrange: Range<Int>, with newElements: some Collection<Element>
    ) {
        elements.replaceSubrange(subrange, with: newElements)
    }
}
