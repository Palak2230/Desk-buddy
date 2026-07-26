# Contributing to Pinky

Thank you for your interest in contributing! Pinky is an open-source project built with love.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/pinky.git`
3. Create a branch: `git checkout -b feature/my-feature`
4. Build and test: `swift build && swift test`
5. Commit with clear messages
6. Push and open a Pull Request

## Code Standards

- Follow existing Clean Architecture layer boundaries
- Use protocols for dependencies (dependency injection)
- Avoid singletons except for system wrappers
- Use `MARK:` sections to organize code
- Document all public APIs with `///` comments
- Keep files under 400 lines
- Run SwiftLint before submitting: `swiftlint lint`

## Architecture Rules

| Layer | Can Import | Cannot Import |
|-------|-----------|---------------|
| PinkyDomain | PinkyCore | Everything else |
| PinkyServices | Domain, Core, Persistence, Notifications | Presentation, UI |
| PinkyPresentation | Domain, UI, Services, Skills, Theme | App |
| PinkyApp | Everything | — |

## Adding a New Skill

See [PluginGuide.md](PluginGuide.md) for the full skill creation guide.

## Adding a New Theme

See [ThemeGuide.md](ThemeGuide.md).

## Pull Request Checklist

- [ ] `swift build` passes
- [ ] `swift test` passes
- [ ] SwiftLint passes
- [ ] No paid APIs or cloud dependencies
- [ ] Public APIs documented
- [ ] PR description includes test plan

## Code of Conduct

Be kind, inclusive, and constructive. We're building something cute — let's keep the community cute too.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
