import PackageDescription

let package = Package(
    name: "FlicSwiftKit",
    dependencies: [
    	.Package(url: "https://github.com/frajaona/socks.git", majorVersion: 1, minor: 0),
    ],
    exclude: ["Sources/FlicCASSocket.swift", "Sources/TcpCASSocket.swift"]
)