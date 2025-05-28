//
//  Player.swift
//  xiuxian
//
//  Created by AI Assistant on 2024.
//

import Foundation

// 修仙境界枚举
enum CultivationRealm: String, CaseIterable, Codable {
    case qiRefining = "练气期"      // 1-9层
    case foundation = "筑基期"      // 初期、中期、后期、大圆满
    case goldenCore = "金丹期"      // 初期、中期、后期、大圆满
    case nascent = "元婴期"         // 初期、中期、后期、大圆满
    case soulTransform = "化神期"   // 初期、中期、后期、大圆满
    case voidMerge = "合体期"       // 初期、中期、后期、大圆满
    case mahayana = "大乘期"        // 初期、中期、后期、大圆满
    case tribulation = "渡劫期"     // 初期、中期、后期、大圆满
    
    // 获取境界等级（用于比较）
    var level: Int {
        switch self {
        case .qiRefining: return 1
        case .foundation: return 2
        case .goldenCore: return 3
        case .nascent: return 4
        case .soulTransform: return 5
        case .voidMerge: return 6
        case .mahayana: return 7
        case .tribulation: return 8
        }
    }
    
    // 获取下一个境界
    var nextRealm: CultivationRealm? {
        let allRealms = CultivationRealm.allCases
        guard let currentIndex = allRealms.firstIndex(of: self),
              currentIndex + 1 < allRealms.count else {
            return nil
        }
        return allRealms[currentIndex + 1]
    }
    
    // 突破到该境界所需修为
    var breakthroughRequirement: Int {
        switch self {
        case .qiRefining: return 0
        case .foundation: return 1000
        case .goldenCore: return 5000
        case .nascent: return 20000
        case .soulTransform: return 80000
        case .voidMerge: return 300000
        case .mahayana: return 1000000
        case .tribulation: return 5000000
        }
    }
}

// 玩家属性
struct PlayerAttributes: Codable {
    var spiritualPower: Int = 10    // 灵力
    var physique: Int = 10          // 体质
    var consciousness: Int = 10      // 神识
    var comprehension: Int = 10      // 悟性
    var luck: Int = 10              // 运气
    
    // 计算总战力
    var totalPower: Int {
        return spiritualPower + physique + consciousness + comprehension + luck
    }
}

// 玩家类
class Player: ObservableObject, Codable {
    
    // MARK: - 基础信息
    @Published var name: String = "道友"
    @Published var currentRealm: CultivationRealm = .qiRefining
    @Published var cultivation: Int = 0              // 当前修为
    @Published var spiritStones: Int = 100          // 灵石
    @Published var experience: Int = 0               // 经验值
    @Published var level: Int = 1                   // 等级
    
    // MARK: - 属性
    @Published var attributes: PlayerAttributes = PlayerAttributes()
    @Published var attributePoints: Int = 0         // 可分配属性点
    
    // MARK: - 背包和装备
    @Published var inventory: [Item] = []           // 背包
    @Published var equippedItems: [Item] = []       // 装备
    
    // MARK: - 技能和功法
    @Published var learnedSkills: [Skill] = []      // 已学习技能
    @Published var activeSkills: [Skill] = []       // 激活的技能
    
    // MARK: - 时间统计
    @Published var totalPlayTime: TimeInterval = 0  // 总游戏时间
    @Published var cultivationTime: TimeInterval = 0 // 修炼时间
    
    // MARK: - 编码相关
    enum CodingKeys: String, CodingKey {
        case name, currentRealm, cultivation, spiritStones, experience, level
        case attributes, attributePoints, inventory, equippedItems
        case learnedSkills, activeSkills, totalPlayTime, cultivationTime
    }
    
    init() {
        // 初始化基础技能
        initializeBasicSkills()
    }
    
    // MARK: - Codable 实现
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        currentRealm = try container.decode(CultivationRealm.self, forKey: .currentRealm)
        cultivation = try container.decode(Int.self, forKey: .cultivation)
        spiritStones = try container.decode(Int.self, forKey: .spiritStones)
        experience = try container.decode(Int.self, forKey: .experience)
        level = try container.decode(Int.self, forKey: .level)
        attributes = try container.decode(PlayerAttributes.self, forKey: .attributes)
        attributePoints = try container.decode(Int.self, forKey: .attributePoints)
        inventory = try container.decode([Item].self, forKey: .inventory)
        equippedItems = try container.decode([Item].self, forKey: .equippedItems)
        learnedSkills = try container.decode([Skill].self, forKey: .learnedSkills)
        activeSkills = try container.decode([Skill].self, forKey: .activeSkills)
        totalPlayTime = try container.decode(TimeInterval.self, forKey: .totalPlayTime)
        cultivationTime = try container.decode(TimeInterval.self, forKey: .cultivationTime)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(currentRealm, forKey: .currentRealm)
        try container.encode(cultivation, forKey: .cultivation)
        try container.encode(spiritStones, forKey: .spiritStones)
        try container.encode(experience, forKey: .experience)
        try container.encode(level, forKey: .level)
        try container.encode(attributes, forKey: .attributes)
        try container.encode(attributePoints, forKey: .attributePoints)
        try container.encode(inventory, forKey: .inventory)
        try container.encode(equippedItems, forKey: .equippedItems)
        try container.encode(learnedSkills, forKey: .learnedSkills)
        try container.encode(activeSkills, forKey: .activeSkills)
        try container.encode(totalPlayTime, forKey: .totalPlayTime)
        try container.encode(cultivationTime, forKey: .cultivationTime)
    }
    
    // MARK: - 游戏更新
    func update(deltaTime: TimeInterval) {
        totalPlayTime += deltaTime
    }
    
    // MARK: - 修炼系统
    func cultivate() {
        let baseGain = 1
        let comprehensionBonus = attributes.comprehension / 10
        let realmMultiplier = currentRealm.level
        
        let cultivationGain = baseGain + comprehensionBonus + realmMultiplier
        
        cultivation += cultivationGain
        cultivationTime += 1.0
        
        // 增加经验
        gainExperience(cultivationGain)
        
        print("🧘‍♂️ 修炼中... 获得修为: \(cultivationGain)")
    }
    
    // MARK: - 境界突破
    func canBreakthrough() -> Bool {
        guard let nextRealm = currentRealm.nextRealm else {
            return false // 已经是最高境界
        }
        return cultivation >= nextRealm.breakthroughRequirement
    }
    
    func breakthrough() {
        guard let nextRealm = currentRealm.nextRealm,
              cultivation >= nextRealm.breakthroughRequirement else {
            return
        }
        
        currentRealm = nextRealm
        
        // 突破奖励
        attributePoints += 5
        spiritStones += 100 * nextRealm.level
        
        // 学习新技能
        if let newSkill = Skill.getRealmSkill(for: nextRealm) {
            learnSkill(newSkill)
        }
        
        print("🌟 成功突破到 \(currentRealm.rawValue)！")
    }
    
    // MARK: - 经验和等级
    func gainExperience(_ amount: Int) {
        experience += amount
        
        // 检查是否升级
        let requiredExp = level * 100
        if experience >= requiredExp {
            levelUp()
        }
    }
    
    private func levelUp() {
        level += 1
        experience -= (level - 1) * 100
        attributePoints += 2
        
        print("🆙 等级提升到 \(level)！获得2点属性点")
    }
    
    // MARK: - 属性分配
    func allocateAttributePoint(to attribute: KeyPath<PlayerAttributes, Int>) -> Bool {
        guard attributePoints > 0 else { return false }
        
        switch attribute {
        case \PlayerAttributes.spiritualPower:
            attributes.spiritualPower += 1
        case \PlayerAttributes.physique:
            attributes.physique += 1
        case \PlayerAttributes.consciousness:
            attributes.consciousness += 1
        case \PlayerAttributes.comprehension:
            attributes.comprehension += 1
        case \PlayerAttributes.luck:
            attributes.luck += 1
        default:
            return false
        }
        
        attributePoints -= 1
        return true
    }
    
    // MARK: - 物品管理
    func addItem(_ item: Item) {
        inventory.append(item)
        print("📦 获得物品: \(item.name)")
    }
    
    func removeItem(_ item: Item) -> Bool {
        if let index = inventory.firstIndex(where: { $0.id == item.id }) {
            inventory.remove(at: index)
            return true
        }
        return false
    }
    
    func equipItem(_ item: Item) -> Bool {
        guard item.type.isEquippable else { return false }
        
        // 卸下同类型装备
        equippedItems.removeAll { $0.type == item.type }
        
        // 装备新物品
        equippedItems.append(item)
        _ = removeItem(item)
        
        print("⚔️ 装备: \(item.name)")
        return true
    }
    
    // MARK: - 技能管理
    func initializeBasicSkills() {
        let basicSkill = Skill.basicAttack()
        learnedSkills.append(basicSkill)
        activeSkills.append(basicSkill)
    }
    
    func learnSkill(_ skill: Skill) {
        if !learnedSkills.contains(where: { $0.id == skill.id }) {
            learnedSkills.append(skill)
            print("📚 学会技能: \(skill.name)")
        }
    }
    
    func activateSkill(_ skill: Skill) -> Bool {
        guard learnedSkills.contains(where: { $0.id == skill.id }),
              activeSkills.count < 4 else { // 最多4个激活技能
            return false
        }
        
        activeSkills.append(skill)
        return true
    }
    
    // MARK: - 灵石管理
    func spendSpiritStones(_ amount: Int) -> Bool {
        guard spiritStones >= amount else { return false }
        spiritStones -= amount
        return true
    }
    
    func earnSpiritStones(_ amount: Int) {
        spiritStones += amount
    }
    
    // MARK: - 战斗力计算
    var totalCombatPower: Int {
        let basepower = attributes.totalPower * currentRealm.level
        let equipmentPower = equippedItems.reduce(0) { $0 + $1.combatPower }
        return basepower + equipmentPower
    }
    
    // MARK: - 调试信息
    func getDetailedInfo() -> String {
        return """
        👤 姓名: \(name)
        🏮 境界: \(currentRealm.rawValue)
        ⚡ 修为: \(cultivation) / \(currentRealm.nextRealm?.breakthroughRequirement ?? 999999999)
        💰 灵石: \(spiritStones)
        🎯 等级: \(level) (经验: \(experience))
        📊 属性点: \(attributePoints)
        
        🔸 灵力: \(attributes.spiritualPower)
        🔸 体质: \(attributes.physique)
        🔸 神识: \(attributes.consciousness)
        🔸 悟性: \(attributes.comprehension)
        🔸 运气: \(attributes.luck)
        
        ⚔️ 战斗力: \(totalCombatPower)
        🎒 物品数量: \(inventory.count)
        📚 技能数量: \(learnedSkills.count)
        ⏱️ 游戏时间: \(Int(totalPlayTime))秒
        """
    }
} 