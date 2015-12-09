import PackageDescription

let package = Package(
    name: "SwiftFoundation",
    dependencies: [
        .Package(url: "://github.com/Zewo/URI.git", majorVersion: 1)
    ]
)
