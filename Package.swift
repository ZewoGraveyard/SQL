import PackageDescription

let package = Package(
    name: "SQL",
    dependencies: [
        .Package(url: "https://github.com/Zewo/String.git", versions: Version(0,7,0)..<Version(0,8,0)),
        .Package(url: "https://github.com/Zewo/URI.git", versions: Version(0,7,0)..<Version(0,8,0)),
        .Package(url: "https://github.com/Zewo/Log.git", versions: Version(0,6,0)..<Version(0,7,0))
    ]
)
