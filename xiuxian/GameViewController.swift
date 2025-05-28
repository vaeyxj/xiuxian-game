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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 直接创建GameScene实例，而不是从.sks文件加载
        let scene = GameScene()
        
        // 获取视图
        if let view = self.view as! SKView? {
            // 设置场景大小为视图大小
            scene.size = view.bounds.size
            
            // 设置缩放模式
            scene.scaleMode = .aspectFill
            
            // 呈现场景
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            // 开发时显示FPS和节点数量，发布时可以关闭
            view.showsFPS = true
            view.showsNodeCount = true
        }
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
