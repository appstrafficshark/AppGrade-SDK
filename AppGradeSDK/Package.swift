
// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "AppGradeSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AppGradeSDK",
            targets: ["AppGradeSDK"]
        ),
    ],
    targets: [
        .target(
            name: "AppGradeSDK",
            path: "Sources/AppGrade" 
        ),
        .testTarget(
            name: "AppGradeSDKTests",
            dependencies: ["AppGradeSDK"],
            path: "Tests/AppGradeTests"
        ),
    ]
)
