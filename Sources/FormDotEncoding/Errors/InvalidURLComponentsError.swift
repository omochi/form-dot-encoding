public import Foundation

public struct InvalidURLComponentsError: Error & CustomStringConvertible {
    public init(
        components: URLComponents,
        file: StaticString = #file, line: UInt = #line
    ) {
        self.components = components
        self.file = file
        self.line = line
    }

    public var components: URLComponents
    public var file: StaticString
    public var line: UInt

    public var description: String {
        "Invalid URL components: \(components), file=\(file), line=\(line)"
    }
}
