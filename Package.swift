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
    name: "form-dot-encoding",
    platforms: [.macOS(.v15)],
    products: [
        .library(
            name: "FormDotEncoding",
            targets: ["FormDotEncoding"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.4"),
    ],
    targets: [
        .target(
            name: "FormDotEncoding",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
            ],
            swiftSettings: swiftSettings(),
        ),
        .testTarget(
            name: "FormDotEncodingTests",
            dependencies: ["FormDotEncoding"],
            swiftSettings: swiftSettings(),
        ),
    ],
    swiftLanguageModes: [.v6]
)
