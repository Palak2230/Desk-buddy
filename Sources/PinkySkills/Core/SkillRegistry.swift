import Foundation
import PinkyCore
import PinkyDomain

/// Registry and lifecycle manager for installable skills.
@MainActor
public final class SkillRegistry: ObservableObject {
    @Published public private(set) var activeSkills: [String: PinkySkill] = [:]

    public init() {}

    public func register(_ skill: PinkySkill) async {
        activeSkills[skill.id] = skill
        await skill.activate()
        PinkyLogger.log("Skills", "Registered skill: \(skill.displayName)")
    }

    public func unregister(id: String) async {
        guard let skill = activeSkills.removeValue(forKey: id) else { return }
        await skill.deactivate()
    }

    public func skill(id: String) -> PinkySkill? {
        activeSkills[id]
    }
}
