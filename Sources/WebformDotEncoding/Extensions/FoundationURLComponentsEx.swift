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
}
