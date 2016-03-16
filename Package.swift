import PackageDescription

let package = Package(
    name: "SQL",
    dependencies: [
    	.Package(url: "https://github.com/Zewo/Data.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/String.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/Log.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Zewo/File.git", majorVersion: 0, minor: 4),
    ]
)
