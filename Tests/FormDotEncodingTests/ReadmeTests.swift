import Testing
import FormDotEncoding

@Suite struct ReadmeTests {
    @Test func example0() throws {
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
    }
}
