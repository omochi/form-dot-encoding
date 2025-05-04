public struct WebformDotEncodingError: Error {
    public enum Reason: Sendable {
        case brokenPercentEncoding
    }

    public init(
        reason: Reason,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        self.reason = reason
        self.file = file
        self.line = line
    }

    public var reason: Reason
    public var file: StaticString
    public var line: UInt
}
