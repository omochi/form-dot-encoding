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
    ],
    targets: [
        .target(
            name: "FormDotEncoding",
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
