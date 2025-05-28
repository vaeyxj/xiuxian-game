//
//  GameScene.swift
//  xiuxian
//
//  Created by 喻西剑 on 2025/5/27.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    
    // MARK: - 游戏UI元素
    private var titleLabel: SKLabelNode?
    private var playerInfoLabel: SKLabelNode?
    private var buttonNodes: [String: SKShapeNode] = [:]
    private var debugInfoLabel: SKLabelNode?
    
    // MARK: - 游戏管理器
    private let gameManager = GameManager.shared
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        
        // 设置场景背景
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        
        setupUI()
        setupButtons()
        
        // 启动游戏
        gameManager.startGame()
        
        print("🎮 游戏场景加载完成")
    }
    
    
    // MARK: - UI设置
    
    private func setupUI() {
        // 标题
        titleLabel = SKLabelNode(text: "修仙战旗")
        titleLabel?.fontName = "PingFangSC-Bold"
        titleLabel?.fontSize = 32
        titleLabel?.fontColor = SKColor.white
        titleLabel?.position = CGPoint(x: size.width / 2, y: size.height - 100)
        if let titleLabel = titleLabel {
            addChild(titleLabel)
        }
        
        // 玩家信息
        playerInfoLabel = SKLabelNode(text: "加载中...")
        playerInfoLabel?.fontName = "PingFangSC-Regular"
        playerInfoLabel?.fontSize = 16
        playerInfoLabel?.fontColor = SKColor.lightGray
        playerInfoLabel?.numberOfLines = 0
        playerInfoLabel?.preferredMaxLayoutWidth = size.width - 40
        playerInfoLabel?.position = CGPoint(x: size.width / 2, y: size.height - 200)
        if let playerInfoLabel = playerInfoLabel {
            addChild(playerInfoLabel)
        }
        
        // 调试信息
        debugInfoLabel = SKLabelNode(text: "")
        debugInfoLabel?.fontName = "PingFangSC-Regular"
        debugInfoLabel?.fontSize = 12
        debugInfoLabel?.fontColor = SKColor.yellow
        debugInfoLabel?.numberOfLines = 0
        debugInfoLabel?.preferredMaxLayoutWidth = size.width - 40
        debugInfoLabel?.position = CGPoint(x: 20, y: 50)
        debugInfoLabel?.horizontalAlignmentMode = .left
        if let debugInfoLabel = debugInfoLabel {
            addChild(debugInfoLabel)
        }
    }
    
    private func setupButtons() {
        let buttonData: [(name: String, title: String, y: CGFloat)] = [
            ("cultivation", "开始修炼", size.height / 2 + 50),
            ("battle", "进入秘境", size.height / 2),
            ("inventory", "查看背包", size.height / 2 - 50),
            ("shop", "访问商店", size.height / 2 - 100),
            ("settings", "游戏设置", size.height / 2 - 150)
        ]
        
        for (index, data) in buttonData.enumerated() {
            let button = createButton(title: data.title, 
                                    position: CGPoint(x: size.width / 2, y: data.y),
                                    name: data.name)
            buttonNodes[data.name] = button
            addChild(button)
            
            let titleNode = SKLabelNode(text: data.title)
            titleNode.fontName = "PingFangSC-Medium"
            titleNode.fontSize = 18
            titleNode.fontColor = SKColor.white
            titleNode.position = CGPoint(x: 0, y: -6)
            titleNode.name = "\(data.name)_title"
            button.addChild(titleNode)
        }
    }
    
    private func createButton(title: String, position: CGPoint, name: String) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        button.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.8)
        button.strokeColor = SKColor.white
        button.lineWidth = 2
        button.position = position
        button.name = name
        return button
    }
    
    // MARK: - 触摸处理
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        handleTouch(on: touchedNode)
    }
    
    private func handleTouch(on node: SKNode) {
        guard let nodeName = node.name else { return }
        
        // 按钮点击动画
        if buttonNodes.keys.contains(nodeName) {
            animateButtonPress(node)
        }
        
        switch nodeName {
        case "cultivation":
            gameManager.changeState(to: .cultivation)
            
        case "battle":
            gameManager.changeState(to: .battle)
            
        case "inventory":
            gameManager.changeState(to: .inventory)
            
        case "shop":
            gameManager.changeState(to: .shop)
            
        case "settings":
            gameManager.changeState(to: .settings)
            
        default:
            break
        }
    }
    
    private func animateButtonPress(_ node: SKNode) {
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        
        node.run(sequence)
        
        // 播放按钮音效
        AudioManager.shared.playUISound(.buttonClick)
    }
    
    
    // MARK: - 游戏更新循环
    
    override func update(_ currentTime: TimeInterval) {
        // 初始化时间
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // 计算时间差
        let deltaTime = currentTime - self.lastUpdateTime
        
        // 更新游戏管理器
        gameManager.update(deltaTime: deltaTime)
        
        // 更新实体
        for entity in self.entities {
            entity.update(deltaTime: deltaTime)
        }
        
        // 更新UI显示
        updateUI()
        
        self.lastUpdateTime = currentTime
    }
    
    private func updateUI() {
        // 更新玩家信息显示
        playerInfoLabel?.text = """
        \(gameManager.player.name) - \(gameManager.player.currentRealm.rawValue)
        修为: \(gameManager.player.cultivation)
        等级: \(gameManager.player.level)
        灵石: \(gameManager.player.spiritStones)
        战斗力: \(gameManager.player.totalCombatPower)
        """
        
        // 更新调试信息
        debugInfoLabel?.text = """
        游戏状态: \(gameManager.currentState)
        运行时间: \(Int(gameManager.player.totalPlayTime))秒
        背包物品: \(gameManager.player.inventory.count)
        已学技能: \(gameManager.player.learnedSkills.count)
        """
        
        // 根据游戏状态更新按钮
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        let currentState = gameManager.currentState
        
        // 重置所有按钮颜色
        for button in buttonNodes.values {
            button.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.8)
        }
        
        // 高亮当前状态对应的按钮
        switch currentState {
        case .cultivation:
            buttonNodes["cultivation"]?.fillColor = SKColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 0.8)
        case .battle:
            buttonNodes["battle"]?.fillColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.8)
        case .inventory:
            buttonNodes["inventory"]?.fillColor = SKColor(red: 0.4, green: 0.8, blue: 0.2, alpha: 0.8)
        case .shop:
            buttonNodes["shop"]?.fillColor = SKColor(red: 0.8, green: 0.8, blue: 0.2, alpha: 0.8)
        case .settings:
            buttonNodes["settings"]?.fillColor = SKColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.8)
        default:
            break
        }
    }
    
    // MARK: - 场景生命周期
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // 设置触摸模式
        isUserInteractionEnabled = true
        
        print("🎮 游戏场景已激活")
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        
        // 暂停游戏
        gameManager.pauseGame()
        
        print("🎮 游戏场景即将离开")
    }
}
