// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftUtilityKit",
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
