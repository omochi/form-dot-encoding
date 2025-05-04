public struct URLQueryElement: Sendable & Hashable & CustomStringConvertible {
    public init(
        path: URLQueryElementPath,
        value: String?
    ) {
        self.path = path
        self.value = value
    }
    
    public var path: URLQueryElementPath
    public var value: String?

    public var description: String {
        var result = ""
        result += path.map(PercentEncoding.encode).joined(separator: ".")
        if var value {
            result += "="
            result += PercentEncoding.encode(string: value)
        }
        return result
    }

    public static func parse(
        string: some StringProtocol,
        file: StaticString = #file, line: UInt = #line
    ) throws -> URLQueryElement {
        let pathString: String
        let value: String?

        if let equalIndex = string.firstIndex(where: { $0 == "=" }) {
            pathString = String(string[..<equalIndex])
            let valueIndex = string.index(after: equalIndex)
            value = try PercentEncoding.decode(
                string: string[valueIndex...], file: file, line: line
            )
        } else {
            pathString = String(string[...])
            value = nil
        }

        let path = try pathString.split(separator: ".").map {
            try PercentEncoding.decode(string: $0, file: file, line: line)
        }

        return URLQueryElement(path: path, value: value)
    }
}
