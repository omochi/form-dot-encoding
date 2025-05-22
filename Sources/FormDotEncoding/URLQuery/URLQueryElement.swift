public import Foundation

public struct URLQueryElement: Sendable & Hashable & CustomStringConvertible {
    public typealias Path = [String]

    public init(path: Path, value: String?) {
        self.path = path
        self.value = value
    }

    public init(
        name: String,
        value: String?
    ) {
        let path = name.split(separator: ".").map { String($0) }

        self.init(path: path, value: value)
    }

    public var path: Path
    public var value: String?

    public var name: String { path.joined(separator: ".") }

    public var description: String {
        serialize(mode: .urlQuery)
    }

    public func serialize(mode: PercentEncoding.Mode) -> String {
        let item = percentEncodedQueryItem(mode: mode)
        var result = item.name
        if let value = item.value {
            result += "=" + value
        }
        return result
    }

    public static func parse<S: StringProtocol>(
        mode: PercentEncoding.Mode,
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
            mode: mode,
            percentEncodedName: name, percentEncodedValue: value,
            file: file, line: line
        )
    }

    public static func parse(
        mode: PercentEncoding.Mode,
        percentEncodedQueryItem item: URLQueryItem,
        file: StaticString = #file, line: UInt = #line
    ) throws(BrokenPercentEncodingError) -> URLQueryElement {
        return try parse(
            mode: mode,
            percentEncodedName: item.name, percentEncodedValue: item.value,
            file: file, line: line
        )
    }

    public static func parse(
        mode: PercentEncoding.Mode,
        percentEncodedName name: some StringProtocol,
        percentEncodedValue value: (some StringProtocol)?,
        file: StaticString = #file, line: UInt = #line
    ) throws(BrokenPercentEncodingError) -> URLQueryElement {
        let name = try PercentEncoding.decode(mode: mode, string: name)
        let value = try value.map { (value) throws(BrokenPercentEncodingError) in
            try PercentEncoding.decode(mode: mode, string: value, file: file, line: line)
        }
        return URLQueryElement(name: name, value: value)
    }

    public func percentEncodedQueryItem(mode: PercentEncoding.Mode) -> URLQueryItem {
        let name = PercentEncoding.encode(mode: mode, string: self.name)
        let value = self.value.map { PercentEncoding.encode(mode: mode, string: $0) }
        return URLQueryItem(name: name, value: value)
    }
}
