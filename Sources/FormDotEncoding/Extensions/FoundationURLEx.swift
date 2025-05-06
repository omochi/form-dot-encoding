public import Foundation

extension URL {
    public var queryObject: URLQuery? {
        guard let query = self.query(percentEncoded: true) else {
            return nil
        }

        return try? URLQuery.parse(percentEncodedString: query)
    }

    public func merging(
        query: some Sequence<URLQueryElement>,
        file: StaticString = #file, line: UInt = #line
    ) throws -> URL {
        guard var c = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            throw InvalidURLError(url: self, file: file, line: line)
        }

        c.merge(query: query)

        guard let url = c.url else {
            throw InvalidURLComponentsError(components: c, file: file, line: line)
        }

        return url
    }
}
