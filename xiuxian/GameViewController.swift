//
//  GameViewController.swift
//  xiuxian
//
//  Created by 喻西剑 on 2025/5/27.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    private var gameScene: GameScene?
    private var skView: SKView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图
        if let view = self.view as? SKView {
            self.skView = view
            view.ignoresSiblingOrder = true
            
            // 开发时显示FPS和节点数量，发布时可以关闭
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 在视图出现后设置场景，确保有正确的尺寸
        setupGameScene()
    }
    
    private func setupGameScene() {
        guard let skView = self.skView else { return }
        
        // 获取视图的实际大小
        let viewSize = skView.bounds.size
        print("📱 视图实际大小: \(viewSize)")
        
        // 创建场景并设置正确大小
        let scene = GameScene(size: viewSize)
        scene.scaleMode = .aspectFill
        
        self.gameScene = scene
        
        // 呈现场景
        skView.presentScene(scene)
        
        print("🎮 场景创建完成，大小: \(scene.size)")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
