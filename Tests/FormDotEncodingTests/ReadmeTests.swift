import Testing
import FormDotEncoding

@Suite struct ReadmeTests {
    @Test func usage() throws {
        struct Profile: Codable {
            var user: User
        }

        struct User: Codable {
            var name: String
            var age: Int
        }

        let profile = Profile(user: User(name: "Alice", age: 20))

        let encoder = FormDotEncoder(mode: .form)
        let result = try encoder.encode(profile)
        #expect(result == "user.age=20&user.name=Alice")
    }

    @Test func distinguishNilAndCollapsed() throws {
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

        let encoder = FormDotEncoder(mode: .form)
        let query = try encoder.encode(profile)
        #expect(query == "primaryAddress.zipCode=12345&secondaryAddress=_")

        let decoder = FormDotDecoder(mode: .form)
        let decoded = try decoder.decode(Profile.self, from: query)
        #expect(decoded == profile)
    }

    @Test func enumCoding() throws {
        enum Status: Codable & Equatable {
            case active
        }

        let status = Status.active

        let encoder = FormDotEncoder(mode: .form)
        let query = try encoder.encode(status)
        #expect(query == "active=_")

        let decoder = FormDotDecoder(mode: .form)
        let decoded = try decoder.decode(Status.self, from: query)
        #expect(decoded == status)
    }
}
