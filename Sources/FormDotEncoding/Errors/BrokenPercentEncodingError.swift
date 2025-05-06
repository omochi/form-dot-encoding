public struct BrokenPercentEncodingError: Error & CustomStringConvertible {
    public init(
        string: some StringProtocol,
        file: StaticString = #file, line: UInt = #line
    ) {
        self.string = String(string)
        self.file = file
        self.line = line
    }

    public var string: String
    public var file: StaticString
    public var line: UInt

    public var description: String {
        "Broken percent encoding: \(string), file=\(file), line=\(line)"
    }
}
