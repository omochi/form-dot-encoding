public import Foundation

extension URL {
    public var queryObject: URLQuery? {
        guard let query = self.query(percentEncoded: true) else {
            return nil
        }

        return try? URLQuery.parse(percentEncodedString: query)
    }
}
