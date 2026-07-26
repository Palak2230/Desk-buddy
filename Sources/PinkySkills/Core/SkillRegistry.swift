import Foundation
import Core
import Domain

/// Registry and lifecycle manager for installable skills.
@MainActor
public final class SkillRegistry: ObservableObject {
    @Published public private(set) var activeSkills: [String: Skill] = [:]

    public init() {}

    public func register(_ skill: Skill) async {
        activeSkills[skill.id] = skill
        await skill.activate()
        AppLogger.log("Skills", "Registered skill: \(skill.displayName)")
    }

    public func unregister(id: String) async {
        guard let skill = activeSkills.removeValue(forKey: id) else { return }
        await skill.deactivate()
    }

    public func skill(id: String) -> Skill? {
        activeSkills[id]
    }
}
