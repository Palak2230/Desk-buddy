# Installation

## Prerequisites

- **macOS 13.0+** (Ventura or later)
- **Xcode 15+** (recommended) or Swift 5.9+ command-line tools
- **Git**

## Build from Source

### 1. Clone the repository

```bash
git clone https://github.com/your-org/pinky.git
cd pinky
```

### 2. Build

```bash
swift build
```

### 3. Run

```bash
swift run Pinky
```

Pinky will appear as a menu bar icon (heart) and a floating companion in the bottom-right corner of your screen.

## Build with Xcode

1. Open the project folder in Xcode:
   ```bash
   open Package.swift
   ```
2. Select the **Pinky** scheme
3. Press **Cmd+R** to build and run

## Development Tools

### SwiftLint

```bash
brew install swiftlint
swiftlint lint
```

### SwiftFormat

```bash
brew install swiftformat
swiftformat .
```

### Run Tests

```bash
swift test
```

## Permissions

On first launch, Pinky requests notification permissions for water reminders. Grant access in **System Settings → Notifications → Pinky**.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Companion not visible | Check bottom-right corner; drag to reposition |
| Menu bar icon missing | Ensure app is running (`swift run Pinky`) |
| Build fails on CLT only | Install full Xcode for GUI app support |
| Notifications not appearing | Grant permission in System Settings |

## Uninstall

Pinky stores data in UserDefaults. To fully remove:

```bash
defaults delete com.pinky.settings
defaults delete com.pinky.water.records
```

Then delete the cloned repository.
