// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "DeskBuddy",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "DeskBuddy",
            targets: ["DeskBuddyApp"]
        ),
    ],
    targets: [
        // MARK: - Application Entry Point

        .executableTarget(
            name: "DeskBuddyApp",
            dependencies: [
                "Core",
                "Presentation",
                "Services",
            ],
            path: "Sources/PinkyApp"
        ),

        // MARK: - Presentation Layer

        .target(
            name: "Presentation",
            dependencies: [
                "Core",
                "Domain",
                "UI",
                "Character",
                "Skills",
                "Theme",
                "Services",
            ],
            path: "Sources/PinkyPresentation"
        ),

        .target(
            name: "UI",
            dependencies: [
                "Core",
                "Theme",
                "Character",
                "Domain",
                "Animations",
            ],
            path: "Sources/PinkyUI"
        ),

        // MARK: - Domain Layer

        .target(
            name: "Domain",
            dependencies: [
                "Core",
            ],
            path: "Sources/PinkyDomain"
        ),

        // MARK: - Services Layer

        .target(
            name: "Services",
            dependencies: [
                "Core",
                "Domain",
                "Persistence",
                "Notifications",
                "Theme",
            ],
            path: "Sources/PinkyServices"
        ),

        .target(
            name: "Persistence",
            dependencies: [
                "Core",
                "Domain",
            ],
            path: "Sources/PinkyPersistence"
        ),

        .target(
            name: "Notifications",
            dependencies: [
                "Core",
                "Domain",
            ],
            path: "Sources/PinkyNotifications"
        ),

        // MARK: - Skills (Plugin System)

        .target(
            name: "Skills",
            dependencies: [
                "Core",
                "Domain",
                "Character",
                "Animations",
            ],
            path: "Sources/PinkySkills"
        ),

        // MARK: - Character Engine

        .target(
            name: "Character",
            dependencies: [
                "Core",
                "Domain",
                "Animations",
            ],
            path: "Sources/PinkyCharacter"
        ),

        // MARK: - Animation Engine

        .target(
            name: "Animations",
            dependencies: [
                "Core",
            ],
            path: "Sources/PinkyAnimations",
            resources: [
                .process("Resources"),
            ]
        ),

        // MARK: - Theme Engine

        .target(
            name: "Theme",
            dependencies: [
                "Core",
            ],
            path: "Sources/PinkyTheme",
            resources: [
                .process("Resources"),
            ]
        ),

        // MARK: - Core (Shared Utilities)

        .target(
            name: "Core",
            dependencies: [],
            path: "Sources/PinkyCore"
        ),

        // MARK: - Tests

        .testTarget(
            name: "DeskBuddyTests",
            dependencies: [
                "Core",
                "Domain",
                "Theme",
                "Animations",
            ],
            path: "Tests/PinkyTests"
        ),
    ]
)
