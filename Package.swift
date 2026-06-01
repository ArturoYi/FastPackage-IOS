// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FastPackage-IOS",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "FastPackage",
            targets: ["FastPackage"]
        ),
    ],
    targets: [
        .target(
            name: "FastPackage",
            path: "Sources/FastPackage"
        ),
        .testTarget(
            name: "FastPackageTests",
            dependencies: ["FastPackage"],
            path: "Tests/FastPackageTests"
        ),
    ]
)
