import Foundation

public enum PercentEncoding {
    private struct Encode {
        static let shared = Encode()

        init() {
            allowed = CharacterSet.urlQueryAllowed
            allowed.remove(charactersIn: "?&=;+:/")
            allowed.insert(" ")
        }

        var allowed: CharacterSet

        func encode(string: some StringProtocol) -> String {
            let string = string.addingPercentEncoding(withAllowedCharacters: allowed)!
            return string.replacingOccurrences(of: " ", with: "+")
        }
    }

    public static func encode(string: some StringProtocol) -> String {
        Encode.shared.encode(string: string)
    }

    public static func decode(
        string: some StringProtocol,
        file: StaticString = #file, line: UInt = #line
    ) throws(BrokenPercentEncodingError) -> String {
        let string = string.replacingOccurrences(of: "+", with: " ")
        guard let string = string.removingPercentEncoding else {
            throw BrokenPercentEncodingError(string: string, file: file, line: line)
        }
        return string
    }
}
