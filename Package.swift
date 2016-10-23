import PackageDescription

let package = Package(
    name: "FlicSwiftKit",
    dependencies: [
    	.Package(url: "https://github.com/robbiehanson/CocoaAsyncSocket.git", majorVersion: 7, minor: 5, patch: 0),
    ]
)