# Installation

## Prerequisites

- **macOS 14.0+** (Sonoma or later)
- **Xcode 15+** (recommended) or Swift 5.9+ command-line tools
- **Git**

## Build from Source

### 1. Clone the repository

```bash
git clone https://github.com/Palak2230/Desk-buddy.git
cd Desk-buddy
```

### 2. Build

```bash
swift build
```

### 3. Run

```bash
swift run DeskBuddy
```

Desk Buddy will appear as a menu bar icon (heart) and a floating companion in the bottom-right corner of your screen.

## Build with Xcode

1. Open the project folder in Xcode:
   ```bash
   open Package.swift
   ```
2. Select the **DeskBuddy** scheme
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

On first launch, Desk Buddy requests notification permissions for water reminders. Grant access in **System Settings → Notifications → Desk Buddy**.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Companion not visible | Check bottom-right corner; drag to reposition |
| Menu bar icon missing | Ensure app is running (`swift run DeskBuddy`) |
| Build fails on CLT only | Install full Xcode for GUI app support |
| Notifications not appearing | Grant permission in System Settings |

## Uninstall

Desk Buddy stores data in UserDefaults. To fully remove:

```bash
defaults delete com.palakagarwal.deskbuddy.settings
defaults delete com.palakagarwal.deskbuddy.water.records
```

Then delete the cloned repository.
