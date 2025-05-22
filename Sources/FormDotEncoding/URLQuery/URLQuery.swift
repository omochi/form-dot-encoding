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
        serialize(mode: .urlQuery)
    }

    public func serialize(mode: PercentEncoding.Mode) -> String {
        elements.map { $0.serialize(mode: mode) }.joined(separator: "&")
    }

    public static func parse(
        mode: PercentEncoding.Mode,
        percentEncodedString string: some StringProtocol,
        file: StaticString = #file, line: UInt = #line
    ) throws(BrokenPercentEncodingError) -> URLQuery {
        let elements = try string.split(separator: "&").map { (element) throws(BrokenPercentEncodingError) in
            try URLQueryElement.parse(mode: mode, percentEncodedString: element, file: file, line: line)
        }
        return URLQuery(elements)
    }

    public static func parse(
        mode: PercentEncoding.Mode,
        percentEncodedQueryItems items: [URLQueryItem],
        file: StaticString = #file, line: UInt = #line
    ) throws(BrokenPercentEncodingError) -> URLQuery {
        let elements = try items.map { (item) throws(BrokenPercentEncodingError) in
            try URLQueryElement.parse(mode: mode, percentEncodedQueryItem: item, file: file, line: line)
        }
        return URLQuery(elements)
    }

    public func percentEncodedQueryItems(mode: PercentEncoding.Mode) -> [URLQueryItem] {
        elements.map { $0.percentEncodedQueryItem(mode: mode) }
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
