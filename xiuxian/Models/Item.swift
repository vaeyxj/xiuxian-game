//
//  Item.swift
//  xiuxian
//
//  Created by AI Assistant on 2024.
//

import Foundation

// 物品品质枚举
enum ItemQuality: String, CaseIterable, Codable {
    case common = "普通"       // 白色
    case uncommon = "良好"     // 绿色
    case rare = "稀有"         // 蓝色
    case epic = "史诗"         // 紫色
    case legendary = "传说"    // 橙色
    case mythical = "神话"     // 红色
    
    var color: String {
        switch self {
        case .common: return "#FFFFFF"
        case .uncommon: return "#00FF00"
        case .rare: return "#0080FF"
        case .epic: return "#8000FF"
        case .legendary: return "#FF8000"
        case .mythical: return "#FF0000"
        }
    }
    
    var powerMultiplier: Double {
        switch self {
        case .common: return 1.0
        case .uncommon: return 1.2
        case .rare: return 1.5
        case .epic: return 2.0
        case .legendary: return 3.0
        case .mythical: return 5.0
        }
    }
}

// 物品类型枚举
enum ItemType: String, CaseIterable, Codable {
    // 装备类
    case weapon = "武器"       // 法器、剑、刀等
    case armor = "护甲"        // 防具
    case accessory = "饰品"    // 戒指、项链等
    
    // 消耗品类
    case pill = "丹药"         // 回复、增益丹药
    case material = "材料"     // 炼制材料
    case scroll = "秘籍"       // 功法秘籍
    
    // 特殊物品
    case treasure = "至宝"     // 特殊宝物
    case quest = "任务物品"    // 任务相关
    
    var isEquippable: Bool {
        switch self {
        case .weapon, .armor, .accessory:
            return true
        default:
            return false
        }
    }
    
    var isConsumable: Bool {
        switch self {
        case .pill, .scroll:
            return true
        default:
            return false
        }
    }
}

// 物品属性
struct ItemAttributes: Codable {
    var attack: Int = 0          // 攻击力
    var defense: Int = 0         // 防御力
    var spiritualPower: Int = 0  // 灵力加成
    var health: Int = 0          // 生命值加成
    var criticalRate: Double = 0 // 暴击率
    var dodgeRate: Double = 0    // 闪避率
    
    static func +(lhs: ItemAttributes, rhs: ItemAttributes) -> ItemAttributes {
        return ItemAttributes(
            attack: lhs.attack + rhs.attack,
            defense: lhs.defense + rhs.defense,
            spiritualPower: lhs.spiritualPower + rhs.spiritualPower,
            health: lhs.health + rhs.health,
            criticalRate: lhs.criticalRate + rhs.criticalRate,
            dodgeRate: lhs.dodgeRate + rhs.dodgeRate
        )
    }
}

// 物品效果
struct ItemEffect: Codable {
    var type: EffectType
    var value: Int
    var duration: TimeInterval // 持续时间（秒）
    
    enum EffectType: String, Codable {
        case healHP = "回复生命"
        case restoreMP = "回复法力"
        case increaseAttack = "增加攻击"
        case increaseDefense = "增加防御"
        case increaseSpeed = "增加速度"
        case breakthrough = "突破辅助"
    }
}

// 物品类
struct Item: Codable, Identifiable, Equatable {
    let id: UUID = UUID()
    var name: String
    var description: String
    var type: ItemType
    var quality: ItemQuality
    var level: Int = 1
    var price: Int
    var attributes: ItemAttributes
    var effects: [ItemEffect] = []
    var iconName: String = "default_item" // 预留图标变量
    var maxStack: Int = 1 // 最大堆叠数量
    var currentStack: Int = 1 // 当前堆叠数量
    
    // 计算战斗力
    var combatPower: Int {
        let basePower = attributes.attack + attributes.defense + attributes.spiritualPower
        let qualityBonus = Int(Double(basePower) * quality.powerMultiplier)
        let levelBonus = level * 10
        return qualityBonus + levelBonus
    }
    
    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - 静态创建方法
    
    // 生成随机稀有物品
    static func generateRareItem() -> Item {
        let rareTypes: [ItemType] = [.weapon, .armor, .accessory, .treasure]
        let randomType = rareTypes.randomElement() ?? .weapon
        let randomQuality: ItemQuality = Bool.random() ? .rare : .epic
        
        switch randomType {
        case .weapon:
            return createWeapon(quality: randomQuality)
        case .armor:
            return createArmor(quality: randomQuality)
        case .accessory:
            return createAccessory(quality: randomQuality)
        case .treasure:
            return createTreasure(quality: randomQuality)
        default:
            return createWeapon(quality: randomQuality)
        }
    }
    
    // 创建武器
    static func createWeapon(quality: ItemQuality = .common) -> Item {
        let weaponNames = [
            "青锋剑", "烈火刀", "寒冰枪", "雷电棍", "玄铁锤",
            "碧玉箫", "紫金钟", "白玉扇", "黑曜石", "星辰剑"
        ]
        
        let name = weaponNames.randomElement() ?? "无名武器"
        let baseAttack = Int.random(in: 10...30)
        let levelMultiplier = Double(quality.powerMultiplier)
        
        return Item(
            name: "\(quality.rawValue)\(name)",
            description: "锋利的修仙武器，蕴含强大的灵力",
            type: .weapon,
            quality: quality,
            level: Int.random(in: 1...5),
            price: Int(Double(baseAttack * 10) * levelMultiplier),
            attributes: ItemAttributes(
                attack: Int(Double(baseAttack) * levelMultiplier),
                spiritualPower: Int(Double(baseAttack / 2) * levelMultiplier)
            ),
            iconName: "weapon_\(quality.rawValue)"
        )
    }
    
    // 创建护甲
    static func createArmor(quality: ItemQuality = .common) -> Item {
        let armorNames = [
            "金蚕丝袍", "玄武甲", "青龙袍", "白虎衣", "朱雀羽衣",
            "麒麟护甲", "凤凰法袍", "龙鳞甲", "仙鹤羽衣", "神兽护甲"
        ]
        
        let name = armorNames.randomElement() ?? "无名护甲"
        let baseDefense = Int.random(in: 8...25)
        let levelMultiplier = Double(quality.powerMultiplier)
        
        return Item(
            name: "\(quality.rawValue)\(name)",
            description: "坚固的修仙护甲，能抵御强大攻击",
            type: .armor,
            quality: quality,
            level: Int.random(in: 1...5),
            price: Int(Double(baseDefense * 12) * levelMultiplier),
            attributes: ItemAttributes(
                defense: Int(Double(baseDefense) * levelMultiplier),
                health: Int(Double(baseDefense * 5) * levelMultiplier)
            ),
            iconName: "armor_\(quality.rawValue)"
        )
    }
    
    // 创建饰品
    static func createAccessory(quality: ItemQuality = .common) -> Item {
        let accessoryNames = [
            "聚灵戒", "护心镜", "避邪珠", "定魂铃", "通天环",
            "乾坤袋", "玉佩", "法印", "符咒", "灵符"
        ]
        
        let name = accessoryNames.randomElement() ?? "无名饰品"
        let basePower = Int.random(in: 5...15)
        let levelMultiplier = Double(quality.powerMultiplier)
        
        return Item(
            name: "\(quality.rawValue)\(name)",
            description: "神秘的修仙饰品，蕴含特殊力量",
            type: .accessory,
            quality: quality,
            level: Int.random(in: 1...5),
            price: Int(Double(basePower * 15) * levelMultiplier),
            attributes: ItemAttributes(
                spiritualPower: Int(Double(basePower) * levelMultiplier),
                criticalRate: 0.05 * quality.powerMultiplier
            ),
            iconName: "accessory_\(quality.rawValue)"
        )
    }
    
    // 创建丹药
    static func createPill(type: ItemEffect.EffectType, quality: ItemQuality = .common) -> Item {
        var name: String
        var description: String
        var effectValue: Int
        
        switch type {
        case .healHP:
            name = "回血丹"
            description = "恢复生命值的丹药"
            effectValue = Int.random(in: 50...150)
        case .restoreMP:
            name = "回气丹"
            description = "恢复法力值的丹药"
            effectValue = Int.random(in: 30...100)
        case .increaseAttack:
            name = "力量丹"
            description = "临时增加攻击力的丹药"
            effectValue = Int.random(in: 10...30)
        case .breakthrough:
            name = "破境丹"
            description = "辅助突破境界的珍贵丹药"
            effectValue = Int.random(in: 100...500)
        default:
            name = "神秘丹药"
            description = "效果未知的丹药"
            effectValue = 50
        }
        
        let levelMultiplier = quality.powerMultiplier
        
        return Item(
            name: "\(quality.rawValue)\(name)",
            description: description,
            type: .pill,
            quality: quality,
            level: 1,
            price: Int(Double(effectValue * 5) * levelMultiplier),
            attributes: ItemAttributes(),
            effects: [ItemEffect(type: type, value: Int(Double(effectValue) * levelMultiplier), duration: 300)],
            iconName: "pill_\(type.rawValue)",
            maxStack: 99,
            currentStack: 1
        )
    }
    
    // 创建至宝
    static func createTreasure(quality: ItemQuality = .legendary) -> Item {
        let treasureNames = [
            "混沌珠", "开天斧", "造化玉牌", "太极图", "河图洛书",
            "昆仑镜", "东皇钟", "盘古幡", "诛仙剑", "封神榜"
        ]
        
        let name = treasureNames.randomElement() ?? "神秘至宝"
        let basePower = Int.random(in: 100...300)
        let levelMultiplier = quality.powerMultiplier
        
        return Item(
            name: "\(quality.rawValue)\(name)",
            description: "传说中的至宝，拥有不可思议的力量",
            type: .treasure,
            quality: quality,
            level: Int.random(in: 5...10),
            price: Int(Double(basePower * 50) * levelMultiplier),
            attributes: ItemAttributes(
                attack: Int(Double(basePower) * levelMultiplier * 0.4),
                defense: Int(Double(basePower) * levelMultiplier * 0.3),
                spiritualPower: Int(Double(basePower) * levelMultiplier * 0.3),
                criticalRate: 0.1 * levelMultiplier,
                dodgeRate: 0.05 * levelMultiplier
            ),
            iconName: "treasure_\(quality.rawValue)"
        )
    }
    
    // MARK: - 物品使用
    
    // 使用物品
    mutating func use() -> Bool {
        guard type.isConsumable && currentStack > 0 else { return false }
        
        currentStack -= 1
        print("💊 使用了 \(name)")
        
        // 应用物品效果
        for effect in effects {
            applyEffect(effect)
        }
        
        return true
    }
    
    private func applyEffect(_ effect: ItemEffect) {
        // 这里应该通过委托或通知来应用效果到玩家
        // 暂时只打印日志
        print("✨ 获得效果: \(effect.type.rawValue) +\(effect.value)")
    }
    
    // MARK: - 物品升级
    
    mutating func upgrade() -> Bool {
        guard type.isEquippable else { return false }
        
        level += 1
        
        // 提升属性
        attributes.attack = Int(Double(attributes.attack) * 1.1)
        attributes.defense = Int(Double(attributes.defense) * 1.1)
        attributes.spiritualPower = Int(Double(attributes.spiritualPower) * 1.1)
        attributes.health = Int(Double(attributes.health) * 1.1)
        
        print("⬆️ \(name) 升级到 \(level) 级！")
        return true
    }
} 