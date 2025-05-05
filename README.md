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
