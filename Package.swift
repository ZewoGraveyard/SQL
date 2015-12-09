import PackageDescription

let package = Package(
    name: "SwiftSQL",
    dependencies: [
        .Package(url: "https://github.com/Zewo/URI.git", majorVersion: 0)
    ]
)
