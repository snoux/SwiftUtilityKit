// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUtilityKit",
    products: [
        .library(
            name: "SwiftUtilityKit",
            targets: ["SwiftUtilityKit"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftUtilityKit"
        ),
        .testTarget(
            name: "SwiftUtilityKitTests",
            dependencies: ["SwiftUtilityKit"]
        ),
    ]
)
