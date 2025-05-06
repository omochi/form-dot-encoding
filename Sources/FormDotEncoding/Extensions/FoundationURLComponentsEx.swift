public import Foundation

extension URLComponents {
    public var queryObject: URLQuery? {
        get {
            guard let percentEncodedQueryItems else { return nil }

            return try? URLQuery.parse(percentEncodedQueryItems: percentEncodedQueryItems)
        }
        set {
            percentEncodedQueryItems = newValue?.percentEncodedQueryItems
        }
    }

    public mutating func merge(query: some Sequence<URLQueryElement>) {
        let query = Array(query)
        if query.isEmpty { return }

        var newQuery = self.queryObject ?? URLQuery()
        newQuery.merge(query)
        self.queryObject = newQuery
    }
}
