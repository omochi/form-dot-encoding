import Foundation

public enum PercentEncoding: Sendable {
    public enum Mode: Sendable {
        case urlQuery
        case form

        public var encodedSpace: String {
            switch self {
            case .urlQuery: return "%20"
            case .form: return "+"
            }
        }
    }

    private struct Encode {
        static let shared = Encode()

        init() {
            allowed = CharacterSet.urlQueryAllowed
            allowed.remove(charactersIn: "?&=;+:/")
            allowed.insert(" ")
        }

        var allowed: CharacterSet

        func encode(mode: Mode, string: some StringProtocol) -> String {
            let string = string.addingPercentEncoding(withAllowedCharacters: allowed)!
            return string.replacingOccurrences(of: " ", with: mode.encodedSpace)
        }
    }

    public static func encode(mode: Mode, string: some StringProtocol) -> String {
        Encode.shared.encode(mode: mode, string: string)
    }

    public static func decode(
        mode: Mode,
        string: some StringProtocol,
        file: StaticString = #file, line: UInt = #line
    ) throws(BrokenPercentEncodingError) -> String {
        let string = string.replacingOccurrences(of: mode.encodedSpace, with: " ")
        guard let string = string.removingPercentEncoding else {
            throw BrokenPercentEncodingError(string: string, file: file, line: line)
        }
        return string
    }
}
