//
//  AudioManager.swift
//  xiuxian
//
//  Created by AI Assistant on 2024.
//

import Foundation
import AVFoundation
import UIKit

// 音效类型枚举
enum SoundEffectType: String, CaseIterable {
    case stateChange = "state_change"
    case buttonClick = "button_click"
    case cultivation = "cultivation"
    case breakthrough = "breakthrough"
    case levelUp = "level_up"
    case itemGet = "item_get"
    case skillUse = "skill_use"
    case battleStart = "battle_start"
    case battleWin = "battle_win"
    case battleLose = "battle_lose"
    case error = "error"
    case success = "success"
}

// 背景音乐类型枚举
enum BackgroundMusicType: String, CaseIterable {
    case mainMenu = "main_menu"
    case cultivation = "cultivation_bgm"
    case battle = "battle_bgm"
    case victory = "victory_bgm"
    case peaceful = "peaceful_bgm"
}

// 音效管理器 - 单例模式
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    // MARK: - 音频播放器
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [String: AVAudioPlayer] = [:]
    
    // MARK: - 设置
    @Published var isMusicEnabled: Bool = true {
        didSet {
            if !isMusicEnabled {
                pauseBackgroundMusic()
            } else if let currentMusic = currentBackgroundMusic {
                playBackgroundMusic(currentMusic)
            }
        }
    }
    
    @Published var isSoundEffectEnabled: Bool = true
    @Published var musicVolume: Float = 0.8 {
        didSet {
            backgroundMusicPlayer?.volume = musicVolume
        }
    }
    
    @Published var soundEffectVolume: Float = 0.8
    
    // MARK: - 当前状态
    private var currentBackgroundMusic: BackgroundMusicType?
    private var isInitialized: Bool = false
    
    private init() {
        setupAudioSession()
        preloadSoundEffects()
    }
    
    // MARK: - 音频会话设置
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            isInitialized = true
            print("🔊 音频会话设置成功")
        } catch {
            print("❌ 音频会话设置失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 预加载音效
    
    private func preloadSoundEffects() {
        for soundType in SoundEffectType.allCases {
            // 这里使用占位符音频文件名
            // 实际开发中应该使用真实的音频文件
            let fileName = "placeholder_\(soundType.rawValue)"
            
            // 预留：加载音频文件
            // if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            //     do {
            //         let player = try AVAudioPlayer(contentsOf: url)
            //         player.prepareToPlay()
            //         soundEffectPlayers[soundType.rawValue] = player
            //     } catch {
            //         print("❌ 预加载音效失败: \(fileName)")
            //     }
            // }
        }
        
        print("🎵 音效预加载完成（使用占位符）")
    }
    
    // MARK: - 背景音乐控制
    
    func playBackgroundMusic(_ musicType: BackgroundMusicType, loop: Bool = true) {
        guard isMusicEnabled && isInitialized else { return }
        
        // 如果正在播放相同音乐，直接返回
        if currentBackgroundMusic == musicType && backgroundMusicPlayer?.isPlaying == true {
            return
        }
        
        stopBackgroundMusic()
        
        // 预留：实际音频文件加载
        // let fileName = musicType.rawValue
        // guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
        //     print("❌ 背景音乐文件不存在: \(fileName)")
        //     return
        // }
        
        // 目前使用占位符逻辑
        print("🎵 播放背景音乐: \(musicType.rawValue)")
        currentBackgroundMusic = musicType
        
        // 预留：实际播放逻辑
        // do {
        //     backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
        //     backgroundMusicPlayer?.numberOfLoops = loop ? -1 : 0
        //     backgroundMusicPlayer?.volume = musicVolume
        //     backgroundMusicPlayer?.play()
        //     currentBackgroundMusic = musicType
        // } catch {
        //     print("❌ 播放背景音乐失败: \(error.localizedDescription)")
        // }
    }
    
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
        print("⏸️ 背景音乐已暂停")
    }
    
    func resumeBackgroundMusic() {
        guard isMusicEnabled else { return }
        backgroundMusicPlayer?.play()
        print("▶️ 背景音乐已恢复")
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
        currentBackgroundMusic = nil
        print("⏹️ 背景音乐已停止")
    }
    
    // MARK: - 音效播放
    
    func playUISound(_ soundType: SoundEffectType) {
        guard isSoundEffectEnabled && isInitialized else { return }
        
        // 目前使用占位符逻辑
        print("🔊 播放音效: \(soundType.rawValue)")
        
        // 预留：实际音效播放逻辑
        // if let player = soundEffectPlayers[soundType.rawValue] {
        //     player.volume = soundEffectVolume
        //     player.currentTime = 0
        //     player.play()
        // } else {
        //     print("❌ 音效播放器不存在: \(soundType.rawValue)")
        // }
    }
    
    func playSoundEffect(_ soundType: SoundEffectType, volume: Float? = nil) {
        guard isSoundEffectEnabled && isInitialized else { return }
        
        let effectiveVolume = volume ?? soundEffectVolume
        
        // 目前使用占位符逻辑
        print("🔊 播放音效: \(soundType.rawValue) (音量: \(effectiveVolume))")
        
        // 预留：实际音效播放逻辑
        // if let player = soundEffectPlayers[soundType.rawValue] {
        //     player.volume = effectiveVolume
        //     player.currentTime = 0
        //     player.play()
        // }
    }
    
    // MARK: - 震动反馈
    
    func playHapticFeedback(_ feedbackType: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let impactFeedback = UIImpactFeedbackGenerator(style: feedbackType)
        impactFeedback.impactOccurred()
        print("📳 震动反馈: \(feedbackType)")
    }
    
    func playNotificationFeedback(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(feedbackType)
        print("📳 通知震动: \(feedbackType)")
    }
    
    // MARK: - 游戏状态音效
    
    func playGameStateChangeSound(from oldState: GameState, to newState: GameState) {
        switch newState {
        case .menu:
            playBackgroundMusic(.mainMenu)
            playUISound(.stateChange)
            
        case .cultivation:
            playBackgroundMusic(.cultivation)
            playUISound(.cultivation)
            
        case .battle:
            playBackgroundMusic(.battle)
            playUISound(.battleStart)
            playHapticFeedback(.heavy)
            
        case .inventory, .shop, .settings:
            playUISound(.buttonClick)
            
        default:
            playUISound(.stateChange)
        }
    }
    
    func playPlayerActionSound(action: PlayerAction) {
        switch action {
        case .levelUp:
            playSoundEffect(.levelUp)
            playNotificationFeedback(.success)
            
        case .breakthrough:
            playSoundEffect(.breakthrough)
            playHapticFeedback(.heavy)
            playNotificationFeedback(.success)
            
        case .itemReceived:
            playSoundEffect(.itemGet)
            playHapticFeedback(.light)
            
        case .skillUsed:
            playSoundEffect(.skillUse)
            playHapticFeedback(.medium)
            
        case .error:
            playSoundEffect(.error)
            playNotificationFeedback(.error)
            
        case .success:
            playSoundEffect(.success)
            playNotificationFeedback(.success)
        }
    }
    
    // MARK: - 音量控制
    
    func setMasterVolume(_ volume: Float) {
        musicVolume = volume
        soundEffectVolume = volume
        
        // 更新所有音效播放器的音量
        for player in soundEffectPlayers.values {
            player.volume = volume
        }
        
        print("🔊 主音量设置为: \(volume)")
    }
    
    func fadeOutBackgroundMusic(duration: TimeInterval = 2.0) {
        guard let player = backgroundMusicPlayer else { return }
        
        let originalVolume = player.volume
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            player.volume -= originalVolume / Float(duration / 0.1)
            
            if player.volume <= 0 {
                timer.invalidate()
                self.stopBackgroundMusic()
            }
        }
        
        print("🔊 背景音乐淡出中...")
    }
    
    func fadeInBackgroundMusic(_ musicType: BackgroundMusicType, duration: TimeInterval = 2.0) {
        playBackgroundMusic(musicType)
        
        guard let player = backgroundMusicPlayer else { return }
        
        let targetVolume = musicVolume
        player.volume = 0
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            player.volume += targetVolume / Float(duration / 0.1)
            
            if player.volume >= targetVolume {
                timer.invalidate()
                player.volume = targetVolume
            }
        }
        
        print("🔊 背景音乐淡入中...")
    }
    
    // MARK: - 设置管理
    
    func loadSettings(_ settings: GameSettings) {
        musicVolume = settings.musicVolume
        soundEffectVolume = settings.soundEffectVolume
        print("⚙️ 音频设置已加载")
    }
    
    func saveCurrentSettings() -> (musicVolume: Float, soundEffectVolume: Float) {
        return (musicVolume: musicVolume, soundEffectVolume: soundEffectVolume)
    }
}

// MARK: - 玩家动作枚举

enum PlayerAction {
    case levelUp
    case breakthrough
    case itemReceived
    case skillUsed
    case error
    case success
} 