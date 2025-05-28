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
        
        // 调试输出场景信息
        print("🎮 场景大小: \(size.width) x \(size.height)")
        print("🎮 开始加载游戏UI...")
        
        // 设置修仙风格的渐变背景
        setupBackground()
        
        // 恢复主要游戏UI
        setupUI()
        setupButtons()
        
        // 启动游戏
        gameManager.startGame()
        
        print("🎮 游戏场景加载完成")
    }
    
    private func setupBackground() {
        // 创建深蓝到紫色的渐变背景
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
        
        // 添加星空效果
        for _ in 0..<30 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...1.2))
            star.fillColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: CGFloat.random(in: 0.3...0.7))
            star.strokeColor = SKColor.clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.zPosition = -10
            addChild(star)
            
            // 添加缓慢的闪烁动画
            let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 2.0...4.0))
            let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: Double.random(in: 2.0...4.0))
            let twinkle = SKAction.sequence([fadeOut, fadeIn])
            let repeatTwinkle = SKAction.repeatForever(twinkle)
            star.run(repeatTwinkle)
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI() {
        // 使用固定的安全区域值，确保在所有设备上都能正确显示
        let safeAreaTop: CGFloat = 80  // 为刘海屏和状态栏预留空间
        let safeAreaBottom: CGFloat = 40  // 为home indicator预留空间
        
        // 标题 - 在屏幕顶部
        titleLabel = SKLabelNode(text: "修仙战旗")
        titleLabel?.fontName = "PingFangSC-Bold"
        titleLabel?.fontSize = 36
        titleLabel?.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0) // 金色
        titleLabel?.position = CGPoint(x: size.width / 2, y: size.height - safeAreaTop)
        titleLabel?.zPosition = 10
        if let titleLabel = titleLabel {
            addChild(titleLabel)
            print("📍 标题位置: \(titleLabel.position)")
        }
        
        // 玩家信息 - 在标题下方
        playerInfoLabel = SKLabelNode(text: "加载中...")
        playerInfoLabel?.fontName = "PingFangSC-Regular"
        playerInfoLabel?.fontSize = 16
        playerInfoLabel?.fontColor = SKColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0) // 淡蓝色
        playerInfoLabel?.position = CGPoint(x: size.width / 2, y: size.height - safeAreaTop - 60)
        playerInfoLabel?.zPosition = 10
        if let playerInfoLabel = playerInfoLabel {
            addChild(playerInfoLabel)
            print("📍 玩家信息位置: \(playerInfoLabel.position)")
        }
        
        // 调试信息 - 在左下角
        debugInfoLabel = SKLabelNode()
        debugInfoLabel?.fontName = "PingFangSC-Regular"
        debugInfoLabel?.fontSize = 12
        debugInfoLabel?.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) // 灰色
        debugInfoLabel?.horizontalAlignmentMode = .left
        debugInfoLabel?.position = CGPoint(x: 20, y: safeAreaBottom + 20)
        debugInfoLabel?.zPosition = 10
        if let debugInfoLabel = debugInfoLabel {
            addChild(debugInfoLabel)
            print("📍 调试信息位置: \(debugInfoLabel.position)")
        }
    }
    
    private func setupButtons() {
        // 使用固定的安全区域值
        let safeAreaTop: CGFloat = 80
        let safeAreaBottom: CGFloat = 40
        
        // 计算按钮区域 - 在屏幕中央区域
        let buttonAreaTop = size.height - safeAreaTop - 120 // 标题和玩家信息下方
        let buttonAreaBottom = safeAreaBottom + 80 // 调试信息上方
        let availableHeight = buttonAreaTop - buttonAreaBottom
        let buttonSpacing: CGFloat = availableHeight / 6 // 5个按钮，6个间距
        
        let buttonData: [(name: String, title: String, index: Int)] = [
            ("cultivation", "🧘‍♂️ 开始修炼", 0),
            ("battle", "⚔️ 进入秘境", 1),
            ("inventory", "🎒 查看背包", 2),
            ("shop", "🏪 访问商店", 3),
            ("settings", "⚙️ 游戏设置", 4)
        ]
        
        print("🔵 按钮区域计算 - 顶部: \(buttonAreaTop), 底部: \(buttonAreaBottom), 间距: \(buttonSpacing)")
        
        for data in buttonData {
            let yPosition = buttonAreaTop - CGFloat(data.index) * buttonSpacing
            let button = createButton(title: data.title, position: CGPoint(x: size.width / 2, y: yPosition), name: data.name)
            buttonNodes[data.name] = button
            addChild(button)
            print("🔵 按钮 \(data.name) 位置: \(button.position)")
        }
    }
    
    private func createButton(title: String, position: CGPoint, name: String) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: 280, height: 50), cornerRadius: 15)
        
        // 设置按钮颜色和样式
        button.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 0.9)
        button.strokeColor = SKColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0)
        button.lineWidth = 2
        button.position = position
        button.name = name
        button.zPosition = 5
        
        // 添加按钮标题
        let titleNode = SKLabelNode(text: title)
        titleNode.fontName = "PingFangSC-Medium"
        titleNode.fontSize = 18
        titleNode.fontColor = SKColor.white
        titleNode.position = CGPoint(x: 0, y: -6) // 垂直居中
        titleNode.horizontalAlignmentMode = .center
        titleNode.verticalAlignmentMode = .center
        titleNode.zPosition = 1
        button.addChild(titleNode)
        
        // 添加按钮阴影效果
        let shadowButton = SKShapeNode(rectOf: CGSize(width: 280, height: 50), cornerRadius: 15)
        shadowButton.fillColor = SKColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 0.6)
        shadowButton.strokeColor = SKColor.clear
        shadowButton.position = CGPoint(x: 2, y: -2)
        shadowButton.zPosition = -1
        button.addChild(shadowButton)
        
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
