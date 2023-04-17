// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "LocStringCleaner",
    platforms: [
        .iOS(.v11),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "LocStringCleaner",
            targets: ["LocStringCleaner"]),
        .executable(
            name: "LocStringCleaner-buildtool",
            targets: ["LocStringCleanerBuildTool"]),
    ],
    dependencies: [
        // Add any dependencies here
    ],
    targets: [
        .target(
            name: "LocStringCleaner",
            dependencies: []),
        .executableTarget(
            name: "LocStringCleanerBuildTool",
            dependencies: ["LocStringCleaner"]),
        .testTarget(
            name: "LocStringCleanerTests",
            dependencies: ["LocStringCleaner"]),
    ]
)
