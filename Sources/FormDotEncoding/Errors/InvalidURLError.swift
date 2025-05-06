public import Foundation

public struct InvalidURLError: Error & CustomStringConvertible {
    public init(
        url: URL,
        file: StaticString = #file, line: UInt = #line
    ) {
        self.url = url
        self.file = file
        self.line = line
    }

    public var url: URL
    public var file: StaticString
    public var line: UInt

    public var description: String {
        "Invalid URL: \(url), file=\(file), line=\(line)"
    }
}
