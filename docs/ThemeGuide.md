# Theme Guide

Pinky themes are **JSON-driven** and loaded at runtime from bundled resources.

## Theme JSON Schema

```json
{
  "id": "strawberry-milk",
  "name": "Strawberry Milk",
  "primary": "#FFB6C1",
  "secondary": "#FFF0F5",
  "accent": "#FF69B4",
  "background": "#FFF5F7",
  "surface": "#FFFFFF",
  "text": "#4A3040",
  "speechBubble": "#FFFFFF"
}
```

| Field | Usage |
|-------|-------|
| `id` | Unique identifier, used in settings |
| `name` | Display name in settings picker |
| `primary` | Main brand color, glass card borders |
| `secondary` | Secondary backgrounds, button fills |
| `accent` | CTAs, highlights, stat labels |
| `background` | Dashboard/window background |
| `surface` | Card surfaces |
| `text` | Primary text color |
| `speechBubble` | Speech bubble background |

## Creating a Theme

### 1. Create the JSON file

```
Sources/PinkyTheme/Resources/Themes/your-theme.json
```

### 2. Use hex colors

All colors use `#RRGGBB` format. The `Color+Hex` extension in PinkyCore parses them.

### 3. Add to settings picker

In `SettingsView.swift`, add a picker option:

```swift
Picker("Theme", selection: binding(\.themeID)) {
    Text("Strawberry Milk").tag("strawberry-milk")
    Text("Your Theme").tag("your-theme")
}
```

## Built-in Themes (Planned)

| Theme | ID | Palette |
|-------|----|---------|
| Strawberry Milk | `strawberry-milk` | Pink, blush, white ✅ |
| Sakura | `sakura` | Cherry blossom pink |
| Lavender | `lavender` | Soft purple |
| Cloud | `cloud` | White, sky blue |
| Minimal | `minimal` | Monochrome gray |
| Dark | `dark` | Deep purple, muted pink |

## Using Themes in Views

Themes are injected via SwiftUI environment:

```swift
@Environment(\.pinkyTheme) private var theme

Text("Hello")
    .foregroundStyle(Color(hex: theme.text))
```

Set the theme at the root:

```swift
MyView()
    .environment(\.pinkyTheme, theme)
```

## Loading Themes Programmatically

```swift
let loader = ThemeLoader()
let theme = loader.loadTheme(id: "strawberry-milk")
let allThemes = loader.allThemes()
```

## Design Guidelines

- Keep contrast ratios accessible (WCAG AA minimum)
- Pastel backgrounds with darker text
- Speech bubbles should be white or near-white for readability
- Accent colors for interactive elements only
- Test in both light conditions and dark room environments
