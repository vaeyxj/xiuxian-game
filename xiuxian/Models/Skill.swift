//
//  Skill.swift
//  xiuxian
//
//  Created by AI Assistant on 2024.
//

import Foundation

// 技能类型枚举
enum SkillType: String, CaseIterable, Codable {
    case attack = "攻击"       // 攻击技能
    case defense = "防御"      // 防御技能
    case healing = "治疗"      // 治疗技能
    case buff = "增益"         // 增益技能
    case debuff = "减益"       // 减益技能
    case movement = "移动"     // 移动技能
    case special = "特殊"      // 特殊技能
}

// 五行属性枚举
enum ElementType: String, CaseIterable, Codable {
    case metal = "金"    // 金系
    case wood = "木"     // 木系
    case water = "水"    // 水系
    case fire = "火"     // 火系
    case earth = "土"    // 土系
    case none = "无"     // 无属性
    
    var color: String {
        switch self {
        case .metal: return "#C0C0C0"
        case .wood: return "#228B22"
        case .water: return "#1E90FF"
        case .fire: return "#FF4500"
        case .earth: return "#8B4513"
        case .none: return "#808080"
        }
    }
    
    // 相克关系
    func counters(_ other: ElementType) -> Bool {
        switch (self, other) {
        case (.metal, .wood), (.wood, .earth), (.earth, .water),
             (.water, .fire), (.fire, .metal):
            return true
        default:
            return false
        }
    }
}

// 技能范围类型
enum SkillRange: String, Codable {
    case single = "单体"       // 单个目标
    case line = "直线"         // 直线范围
    case area = "范围"         // 区域范围
    case selfTarget = "自身"    // 只作用于自己
    case all = "全体"          // 全体目标
}

// 技能伤害类型
struct SkillDamage: Codable {
    var baseDamage: Int = 0           // 基础伤害
    var damageMultiplier: Double = 1.0 // 伤害倍率
    var criticalChance: Double = 0.1   // 暴击率
    var criticalMultiplier: Double = 2.0 // 暴击倍率
    var elementType: ElementType = .none // 元素类型
    
    // 计算最终伤害
    func calculateDamage(attackPower: Int) -> Int {
        let damage = Double(baseDamage + attackPower) * damageMultiplier
        let isCritical = Double.random(in: 0...1) < criticalChance
        
        if isCritical {
            return Int(damage * criticalMultiplier)
        } else {
            return Int(damage)
        }
    }
}

// 技能效果
struct SkillEffect: Codable {
    var type: EffectType
    var value: Int
    var duration: TimeInterval = 0 // 持续时间
    var chance: Double = 1.0       // 触发概率
    
    enum EffectType: String, Codable {
        case heal = "治疗"
        case shield = "护盾"
        case buff_attack = "增加攻击"
        case buff_defense = "增加防御"
        case buff_speed = "增加速度"
        case debuff_attack = "减少攻击"
        case debuff_defense = "减少防御"
        case debuff_speed = "减少速度"
        case poison = "中毒"
        case burn = "燃烧"
        case freeze = "冰冻"
        case stun = "眩晕"
        case teleport = "传送"
    }
}

// 技能类
struct Skill: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var type: SkillType
    var element: ElementType
    var range: SkillRange
    var level: Int = 1
    var maxLevel: Int = 10
    var manaCost: Int
    var cooldown: TimeInterval
    var castTime: TimeInterval = 0
    var damage: SkillDamage?
    var effects: [SkillEffect] = []
    var iconName: String = "default_skill" // 预留图标变量
    var unlockRealm: CultivationRealm = .qiRefining
    
    // 技能学习消耗
    var learnCost: Int {
        return level * 100 + Int(unlockRealm.level) * 500
    }
    
    // 技能升级消耗
    var upgradeCost: Int {
        return level * 200 + Int(unlockRealm.level) * 300
    }
    
    static func ==(lhs: Skill, rhs: Skill) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - 技能升级
    
    mutating func levelUp() -> Bool {
        guard level < maxLevel else { return false }
        
        level += 1
        
        // 提升技能属性
        manaCost = Int(Double(manaCost) * 1.1)
        
        if var damage = damage {
            damage.baseDamage = Int(Double(damage.baseDamage) * 1.2)
            damage.damageMultiplier *= 1.05
            self.damage = damage
        }
        
        for i in 0..<effects.count {
            effects[i].value = Int(Double(effects[i].value) * 1.15)
        }
        
        print("⬆️ 技能 \(name) 升级到 \(level) 级！")
        return true
    }
    
    // MARK: - 静态创建方法
    
    // 基础攻击
    static func basicAttack() -> Skill {
        return Skill(
            name: "基础攻击",
            description: "最基本的攻击技能",
            type: .attack,
            element: .none,
            range: .single,
            level: 1,
            maxLevel: 5,
            manaCost: 0,
            cooldown: 1.0,
            damage: SkillDamage(
                baseDamage: 10,
                damageMultiplier: 1.0,
                criticalChance: 0.1
            ),
            iconName: "skill_basic_attack",
            unlockRealm: .qiRefining
        )
    }
    
    // 根据境界获取技能
    static func getRealmSkill(for realm: CultivationRealm) -> Skill? {
        switch realm {
        case .qiRefining:
            return createQiSkill()
        case .foundation:
            return createFoundationSkill()
        case .goldenCore:
            return createGoldenCoreSkill()
        case .nascent:
            return createNascentSkill()
        case .soulTransform:
            return createSoulTransformSkill()
        case .voidMerge:
            return createVoidMergeSkill()
        case .mahayana:
            return createMahayanaSkill()
        case .tribulation:
            return createTribulationSkill()
        }
    }
    
    // 练气期技能
    static func createQiSkill() -> Skill {
        let skills = [
            Skill(
                name: "气劲冲击",
                description: "聚集体内灵气，向敌人发出冲击",
                type: .attack,
                element: .none,
                range: .single,
                manaCost: 10,
                cooldown: 2.0,
                damage: SkillDamage(
                    baseDamage: 20,
                    damageMultiplier: 1.2
                ),
                iconName: "skill_qi_blast",
                unlockRealm: .qiRefining
            ),
            Skill(
                name: "内息调理",
                description: "调理内息，恢复生命力",
                type: .healing,
                element: .none,
                range: .selfTarget,
                manaCost: 15,
                cooldown: 5.0,
                effects: [SkillEffect(type: .heal, value: 50)],
                iconName: "skill_inner_healing",
                unlockRealm: .qiRefining
            )
        ]
        
        return skills.randomElement() ?? basicAttack()
    }
    
    // 筑基期技能
    static func createFoundationSkill() -> Skill {
        let elements = ElementType.allCases.filter { $0 != .none }
        let randomElement = elements.randomElement() ?? .fire
        
        return Skill(
            name: "\(randomElement.rawValue)系掌法",
            description: "运用\(randomElement.rawValue)系灵力的掌法",
            type: .attack,
            element: randomElement,
            range: .single,
            manaCost: 25,
            cooldown: 3.0,
            damage: SkillDamage(
                baseDamage: 40,
                damageMultiplier: 1.5,
                elementType: randomElement
            ),
            iconName: "skill_\(randomElement.rawValue)_palm",
            unlockRealm: .foundation
        )
    }
    
    // 金丹期技能
    static func createGoldenCoreSkill() -> Skill {
        return Skill(
            name: "金丹爆裂",
            description: "引爆体内金丹之力，造成大范围伤害",
            type: .attack,
            element: .metal,
            range: .area,
            manaCost: 50,
            cooldown: 8.0,
            damage: SkillDamage(
                baseDamage: 80,
                damageMultiplier: 2.0,
                criticalChance: 0.2
            ),
            iconName: "skill_golden_core_blast",
            unlockRealm: .goldenCore
        )
    }
    
    // 元婴期技能
    static func createNascentSkill() -> Skill {
        return Skill(
            name: "元婴出窍",
            description: "元婴暂时离体，获得强大力量",
            type: .buff,
            element: .none,
            range: .selfTarget,
            manaCost: 80,
            cooldown: 30.0,
            effects: [
                SkillEffect(type: .buff_attack, value: 100, duration: 10),
                SkillEffect(type: .buff_speed, value: 50, duration: 10)
            ],
            iconName: "skill_nascent_soul",
            unlockRealm: .nascent
        )
    }
    
    // 化神期技能
    static func createSoulTransformSkill() -> Skill {
        return Skill(
            name: "神识攻击",
            description: "使用强大神识直接攻击敌人灵魂",
            type: .attack,
            element: .none,
            range: .line,
            manaCost: 120,
            cooldown: 6.0,
            damage: SkillDamage(
                baseDamage: 150,
                damageMultiplier: 2.5
            ),
            effects: [SkillEffect(type: .stun, value: 1, duration: 2.0, chance: 0.3)],
            iconName: "skill_soul_attack",
            unlockRealm: .soulTransform
        )
    }
    
    // 合体期技能
    static func createVoidMergeSkill() -> Skill {
        return Skill(
            name: "虚空裂缝",
            description: "撕裂虚空，造成空间伤害",
            type: .attack,
            element: .none,
            range: .area,
            manaCost: 200,
            cooldown: 15.0,
            damage: SkillDamage(
                baseDamage: 300,
                damageMultiplier: 3.0,
                criticalChance: 0.25
            ),
            effects: [SkillEffect(type: .teleport, value: 1)],
            iconName: "skill_void_rift",
            unlockRealm: .voidMerge
        )
    }
    
    // 大乘期技能
    static func createMahayanaSkill() -> Skill {
        return Skill(
            name: "天劫降临",
            description: "召唤天劫之力攻击敌人",
            type: .attack,
            element: .none,
            range: .all,
            manaCost: 300,
            cooldown: 20.0,
            castTime: 3.0,
            damage: SkillDamage(
                baseDamage: 500,
                damageMultiplier: 4.0,
                criticalChance: 0.3
            ),
            iconName: "skill_heavenly_tribulation",
            unlockRealm: .mahayana
        )
    }
    
    // 渡劫期技能
    static func createTribulationSkill() -> Skill {
        return Skill(
            name: "破碎虚空",
            description: "最强技能，可以破碎虚空",
            type: .special,
            element: .none,
            range: .all,
            manaCost: 500,
            cooldown: 60.0,
            castTime: 5.0,
            damage: SkillDamage(
                baseDamage: 1000,
                damageMultiplier: 5.0,
                criticalChance: 0.5,
                criticalMultiplier: 3.0
            ),
            iconName: "skill_shatter_void",
            unlockRealm: .tribulation
        )
    }
    
    // MARK: - 技能组合
    
    // 检查技能组合
    static func checkCombo(skills: [Skill]) -> Skill? {
        // 简单的组合检查：同元素技能组合
        let elementGroups = Dictionary(grouping: skills) { $0.element }
        
        for (element, elementSkills) in elementGroups {
            if element != .none && elementSkills.count >= 2 {
                return createComboSkill(element: element, level: elementSkills.map { $0.level }.max() ?? 1)
            }
        }
        
        return nil
    }
    
    // 创建组合技能
    static func createComboSkill(element: ElementType, level: Int) -> Skill {
        return Skill(
            name: "\(element.rawValue)系连击",
            description: "连续使用\(element.rawValue)系技能形成的组合攻击",
            type: .attack,
            element: element,
            range: .area,
            level: level,
            manaCost: 80,
            cooldown: 12.0,
            damage: SkillDamage(
                baseDamage: 100 + level * 20,
                damageMultiplier: 2.5,
                criticalChance: 0.3,
                elementType: element
            ),
            iconName: "skill_\(element.rawValue)_combo",
            unlockRealm: .foundation
        )
    }
} 