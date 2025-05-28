//
//  GameManager.swift
//  xiuxian
//
//  Created by AI Assistant on 2024.
//

import Foundation
import SpriteKit
import GameplayKit

// 游戏状态枚举
enum GameState {
    case menu       // 主菜单
    case cultivation // 修炼界面
    case battle     // 战斗中
    case inventory  // 背包界面
    case shop       // 商店界面
    case settings   // 设置界面
}

// 游戏管理器 - 单例模式
class GameManager: ObservableObject {
    static let shared = GameManager()
    
    // MARK: - 游戏状态
    @Published var currentState: GameState = .menu
    @Published var isGameRunning: Bool = false
    
    // MARK: - 玩家数据
    var player: Player
    
    // MARK: - 游戏配置
    private let saveSystem = SaveSystem.shared
    private let audioManager = AudioManager.shared
    
    // MARK: - 时间管理
    private var lastUpdateTime: TimeInterval = 0
    private var cultivationTimer: Timer?
    
    private init() {
        // 初始化玩家数据
        self.player = Player()
        loadGameData()
    }
    
    // MARK: - 游戏循环
    func startGame() {
        isGameRunning = true
        startCultivationTimer()
        print("🎮 游戏开始运行")
    }
    
    func pauseGame() {
        isGameRunning = false
        stopCultivationTimer()
        print("⏸️ 游戏暂停")
    }
    
    func update(deltaTime: TimeInterval) {
        guard isGameRunning else { return }
        
        lastUpdateTime += deltaTime
        
        // 更新玩家数据
        player.update(deltaTime: deltaTime)
        
        // 每秒检查一次游戏状态
        if lastUpdateTime >= 1.0 {
            checkGameEvents()
            lastUpdateTime = 0
        }
    }
    
    // MARK: - 状态管理
    func changeState(to newState: GameState) {
        let oldState = currentState
        currentState = newState
        
        print("🔄 游戏状态切换: \(oldState) -> \(newState)")
        
        // 状态切换时的特殊处理
        switch newState {
        case .cultivation:
            startCultivationTimer()
        case .battle:
            prepareBattle()
        default:
            break
        }
        
        // 播放切换音效
        audioManager.playUISound(.stateChange)
    }
    
    // MARK: - 修炼系统
    private func startCultivationTimer() {
        stopCultivationTimer()
        cultivationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.player.cultivate()
            self.saveGameData()
        }
    }
    
    private func stopCultivationTimer() {
        cultivationTimer?.invalidate()
        cultivationTimer = nil
    }
    
    // MARK: - 战斗准备
    private func prepareBattle() {
        // 战斗前的准备工作
        print("⚔️ 准备进入战斗")
    }
    
    // MARK: - 游戏事件检查
    private func checkGameEvents() {
        // 检查境界突破
        if player.canBreakthrough() {
            player.breakthrough()
            print("🌟 恭喜突破到 \(player.currentRealm.rawValue) 境界！")
        }
        
        // 检查随机事件
        checkRandomEvents()
    }
    
    private func checkRandomEvents() {
        let randomValue = Int.random(in: 1...1000)
        
        switch randomValue {
        case 1...5: // 0.5% 概率获得稀有物品
            let rareItem = Item.generateRareItem()
            player.addItem(rareItem)
            print("✨ 获得稀有物品: \(rareItem.name)")
            
        case 6...20: // 1.5% 概率遇到随机事件
            triggerRandomEvent()
            
        default:
            break
        }
    }
    
    private func triggerRandomEvent() {
        let events = ["发现神秘洞府", "遇到前辈高人", "发现灵草", "遭遇心魔"]
        let event = events.randomElement() ?? "无事发生"
        print("🎲 随机事件: \(event)")
    }
    
    // MARK: - 数据管理
    func saveGameData() {
        saveSystem.savePlayerData(player)
    }
    
    func loadGameData() {
        if let savedPlayer = saveSystem.loadPlayerData() {
            self.player = savedPlayer
            print("📁 游戏数据加载成功")
        } else {
            print("📁 创建新的游戏存档")
        }
    }
    
    func resetGameData() {
        player = Player()
        saveSystem.clearSaveData()
        print("🗑️ 游戏数据已重置")
    }
    
    // MARK: - 调试功能
    func getGameInfo() -> String {
        return """
        🎮 游戏状态: \(currentState)
        👤 玩家: \(player.name)
        🏮 境界: \(player.currentRealm.rawValue)
        ⚡ 修为: \(player.cultivation)
        💰 灵石: \(player.spiritStones)
        🎒 物品数量: \(player.inventory.count)
        """
    }
} 