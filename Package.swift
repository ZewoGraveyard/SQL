import PackageDescription

let package = Package(
    name: "SwiftFoundation",
    dependencies: [
        .Package(url: "://github.com/PureSwift/SwiftFoundation.git", majorVersion: 1)
    ]
)
