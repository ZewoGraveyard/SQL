import PackageDescription

let package = Package(
    name: "SQL",
    dependencies: [
        .Package(url: "https://github.com/Zewo/String.git", majorVersion: 0, minor: 5),
        .Package(url: "https://github.com/Zewo/URI.git", majorVersion: 0, minor: 5),
        .Package(url: "https://github.com/Zewo/Log.git", majorVersion: 0, minor: 5)
    ]
)
