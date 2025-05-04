public import Foundation

public struct URLQueryElement: Sendable & Hashable & CustomStringConvertible {
    public typealias Path = [String]

    public init(
        path: Path,
        value: String?
    ) {
        self.path = path
        self.value = value
    }
    
    public var path: Path
    public var value: String?

    public var description: String {
        let item = percentEncodedQueryItem
        var result = item.name
        if let value = item.value {
            result += "=" + value
        }
        return result
    }

    public static func parse<S: StringProtocol>(
        percentEncodedString string: S,
        file: StaticString = #file, line: UInt = #line
    ) throws(BrokenPercentEncodingError) -> URLQueryElement {
        let name: S.SubSequence
        let value: S.SubSequence?

        if let equalIndex = string.firstIndex(where: { $0 == "=" }) {
            name = string[..<equalIndex]
            let valueIndex = string.index(after: equalIndex)
            value = string[valueIndex...]
        } else {
            name = string[...]
            value = nil
        }

        return try parse(
            percentEncodedName: name, percentEncodedValue: value,
            file: file, line: line
        )
    }

    public static func parse(
        percentEncodedQueryItem item: URLQueryItem,
        file: StaticString = #file, line: UInt = #line
    ) throws(BrokenPercentEncodingError) -> URLQueryElement {
        return try parse(
            percentEncodedName: item.name, percentEncodedValue: item.value,
            file: file, line: line
        )
    }

    public static func parse(
        percentEncodedName name: some StringProtocol,
        percentEncodedValue value: (some StringProtocol)?,
        file: StaticString = #file, line: UInt = #line
    ) throws(BrokenPercentEncodingError) -> URLQueryElement {
        let path = try name.split(separator: ".").map { (name) throws(BrokenPercentEncodingError) in
            try PercentEncoding.decode(string: name, file: file, line: line)
        }
        let value = try value.map { (value) throws(BrokenPercentEncodingError) in
            try PercentEncoding.decode(string: value, file: file, line: line)
        }
        return URLQueryElement(path: path, value: value)
    }

    public var percentEncodedQueryItem: URLQueryItem {
        let name = path.map(PercentEncoding.encode).joined(separator: ".")
        let value = self.value.map(PercentEncoding.encode)
        return URLQueryItem(name: name, value: value)
    }
}
