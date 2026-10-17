// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftUtilityKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SwiftUtilityKit",
            targets: ["SwiftUtilityKit"]
        )
    ],
    targets: [
        .target(
            name: "SwiftUtilityKit",
            resources: [
                .process("Resources/AppleDeviceList.txt")
            ]
        ),
        .testTarget(
            name: "SwiftUtilityKitTests",
            dependencies: ["SwiftUtilityKit"]
        )
    ]
)
