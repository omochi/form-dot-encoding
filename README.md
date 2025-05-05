# form-dot-encoding

Encodes `Codable` data as `www-form-urlencoded` using dot-separated keys.

# Features

- Encodes and decodes Swift `Codable` data as `application/x-www-form-urlencoded`
- Expands nested structures into dot-separated keys
- Conforms to the standard `Encodable` and `Decodable` protocols

# Installation

```swift
.package(url: "https://github.com/omochi/form-dot-encoding.git", from: "0.1.0")
```

# Usage

```swift
struct Profile: Codable {
    let user: User
}

struct User: Codable {
    let name: String
    let age: Int
}

let profile = Profile(user: User(name: "Alice", age: 20))

let encoder = FormDotEncoder()
let result = try encoder.encode(profile)
#expect(result == "user.age=20&user.name=Alice")
```

# Advanced Features

## Distinguishing Nil and Empty Containers

By inserting a placeholder value (`_`) for empty containers, the encoder preserves the distinction between `nil` and empty objects. This ensures that even collapsed or empty objects and arrays are round-trip encodable and decodable.

```swift
struct Profile: Codable & Equatable {
    var primaryAddress: Address?
    var secondaryAddress: Address?
    var billingAddress: Address?
}

struct Address: Codable & Equatable {
    var zipCode: String?
}

let profile = Profile(
    primaryAddress: Address(zipCode: "12345"),
    secondaryAddress: Address(),
    billingAddress: nil
)

let encoder = FormDotEncoder()
let query = try encoder.encode(profile)
#expect(query == "primaryAddress.zipCode=12345&secondaryAddress=_")

let decoder = FormDotDecoder()
let decoded = try decoder.decode(Profile.self, from: query)
#expect(decoded == profile)
```

## Further Examples and Tests

For more details and edge cases, check the [test cases](Tests/FormDotEncodingTests).
