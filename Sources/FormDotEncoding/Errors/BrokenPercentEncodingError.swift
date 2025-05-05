public struct BrokenPercentEncodingError: Error {
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
}
