import Foundation

public enum PercentEncoding {
    private struct Encode {
        static let shared = Encode()

        init() {
            allowed = CharacterSet.urlQueryAllowed
            allowed.remove(charactersIn: "?&=;+:/")
        }

        var allowed: CharacterSet

        func encode(string: some StringProtocol) -> String {
            return string.addingPercentEncoding(withAllowedCharacters: allowed)!
        }
    }

    public static func encode(string: some StringProtocol) -> String {
        Encode.shared.encode(string: string)
    }

    public static func decode(
        string: some StringProtocol,
        file: StaticString = #file, line: UInt = #line
    ) throws(WebformDotEncodingError) -> String {
        guard let string = string.removingPercentEncoding else {
            throw WebformDotEncodingError(reason: .brokenPercentEncoding, file: file, line: line)
        }
        return string
    }
}
