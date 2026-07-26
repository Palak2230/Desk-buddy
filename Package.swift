// swift-tools-version: 5.9
// Pinky — Aesthetic macOS desktop companion
// https://github.com/palak/pinky

import PackageDescription

let package = Package(
    name: "Pinky",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(
            name: "Pinky",
            targets: ["PinkyApp"]
        ),
    ],
    targets: [
        // MARK: - Application Entry Point

        .executableTarget(
            name: "PinkyApp",
            dependencies: [
                "PinkyCore",
                "PinkyPresentation",
                "PinkyServices",
            ],
            path: "Sources/PinkyApp"
        ),

        // MARK: - Presentation Layer

        .target(
            name: "PinkyPresentation",
            dependencies: [
                "PinkyCore",
                "PinkyDomain",
                "PinkyUI",
                "PinkyCharacter",
                "PinkySkills",
                "PinkyTheme",
            ],
            path: "Sources/PinkyPresentation"
        ),

        .target(
            name: "PinkyUI",
            dependencies: [
                "PinkyCore",
                "PinkyTheme",
                "PinkyCharacter",
            ],
            path: "Sources/PinkyUI"
        ),

        // MARK: - Domain Layer

        .target(
            name: "PinkyDomain",
            dependencies: [
                "PinkyCore",
            ],
            path: "Sources/PinkyDomain"
        ),

        // MARK: - Services Layer

        .target(
            name: "PinkyServices",
            dependencies: [
                "PinkyCore",
                "PinkyDomain",
                "PinkyPersistence",
                "PinkyNotifications",
            ],
            path: "Sources/PinkyServices"
        ),

        .target(
            name: "PinkyPersistence",
            dependencies: [
                "PinkyCore",
                "PinkyDomain",
            ],
            path: "Sources/PinkyPersistence"
        ),

        .target(
            name: "PinkyNotifications",
            dependencies: [
                "PinkyCore",
                "PinkyDomain",
            ],
            path: "Sources/PinkyNotifications"
        ),

        // MARK: - Skills (Plugin System)

        .target(
            name: "PinkySkills",
            dependencies: [
                "PinkyCore",
                "PinkyDomain",
                "PinkyCharacter",
                "PinkyAnimations",
            ],
            path: "Sources/PinkySkills"
        ),

        // MARK: - Character Engine

        .target(
            name: "PinkyCharacter",
            dependencies: [
                "PinkyCore",
                "PinkyDomain",
                "PinkyAnimations",
            ],
            path: "Sources/PinkyCharacter"
        ),

        // MARK: - Animation Engine

        .target(
            name: "PinkyAnimations",
            dependencies: [
                "PinkyCore",
            ],
            path: "Sources/PinkyAnimations"
        ),

        // MARK: - Theme Engine

        .target(
            name: "PinkyTheme",
            dependencies: [
                "PinkyCore",
            ],
            path: "Sources/PinkyTheme",
            resources: [
                .process("Resources"),
            ]
        ),

        // MARK: - Core (Shared Utilities)

        .target(
            name: "PinkyCore",
            dependencies: [],
            path: "Sources/PinkyCore"
        ),

        // MARK: - Tests

        .testTarget(
            name: "PinkyTests",
            dependencies: [
                "PinkyCore",
                "PinkyDomain",
                "PinkyTheme",
                "PinkyAnimations",
            ],
            path: "Tests/PinkyTests"
        ),
    ]
)
