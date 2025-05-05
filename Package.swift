// swift-tools-version: 6.1

import PackageDescription

func swiftSettings() -> [SwiftSetting] {
    return [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
}

let package = Package(
    name: "webform-dot-encoding",
    platforms: [.macOS(.v15)],
    products: [
        .library(
            name: "WebformDotEncoding",
            targets: ["WebformDotEncoding"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.4"),
    ],
    targets: [
        .target(
            name: "WebformDotEncoding",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
            ],
            swiftSettings: swiftSettings(),
        ),
        .testTarget(
            name: "WebformDotEncodingTests",
            dependencies: ["WebformDotEncoding"],
            swiftSettings: swiftSettings(),
        ),
    ],
    swiftLanguageModes: [.v6]
)
