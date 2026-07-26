import XCTest
@testable import Core
@testable import Domain
@testable import Theme

final class CoreTests: XCTestCase {
    func testDefaultSettings() {
        let settings = AppSettings.default
        XCTAssertEqual(settings.reminderIntervalMinutes, 60)
        XCTAssertEqual(settings.themeID, "strawberry-milk")
    }

    func testCharacterStatePriority() {
        XCTAssertGreaterThan(CharacterState.celebrate.priority, CharacterState.idle.priority)
        XCTAssertTrue(CharacterState.idle.isLooping)
        XCTAssertFalse(CharacterState.wave.isLooping)
    }

    func testFallbackTheme() {
        let theme = ThemeLoader.fallbackTheme
        XCTAssertEqual(theme.id, "strawberry-milk")
        XCTAssertFalse(theme.name.isEmpty)
    }
}
