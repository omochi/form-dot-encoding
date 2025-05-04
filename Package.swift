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
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "WebformDotEncoding",
            targets: ["WebformDotEncoding"]
        ),
    ],
    targets: [
        .target(
            name: "WebformDotEncoding",
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
