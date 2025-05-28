//
//  SaveSystem.swift
//  xiuxian
//
//  Created by AI Assistant on 2024.
//

import Foundation

// 存档系统 - 单例模式
class SaveSystem {
    static let shared = SaveSystem()
    
    // MARK: - 存档文件路径
    private let documentsDirectory: URL
    private let playerDataFileName = "player_save.json"
    private let gameSettingsFileName = "game_settings.json"
    
    private init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, 
                                                     in: .userDomainMask).first!
    }
    
    // MARK: - 玩家数据存档
    
    func savePlayerData(_ player: Player) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(player)
            
            let url = documentsDirectory.appendingPathComponent(playerDataFileName)
            try data.write(to: url)
            
            print("💾 玩家数据保存成功")
        } catch {
            print("❌ 保存玩家数据失败: \(error.localizedDescription)")
        }
    }
    
    func loadPlayerData() -> Player? {
        do {
            let url = documentsDirectory.appendingPathComponent(playerDataFileName)
            
            guard FileManager.default.fileExists(atPath: url.path) else {
                print("📁 存档文件不存在，创建新游戏")
                return nil
            }
            
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let player = try decoder.decode(Player.self, from: data)
            print("📖 玩家数据加载成功")
            return player
            
        } catch {
            print("❌ 加载玩家数据失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - 游戏设置存档
    
    func saveGameSettings(_ settings: GameSettings) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(settings)
            
            let url = documentsDirectory.appendingPathComponent(gameSettingsFileName)
            try data.write(to: url)
            
            print("⚙️ 游戏设置保存成功")
        } catch {
            print("❌ 保存游戏设置失败: \(error.localizedDescription)")
        }
    }
    
    func loadGameSettings() -> GameSettings {
        do {
            let url = documentsDirectory.appendingPathComponent(gameSettingsFileName)
            
            guard FileManager.default.fileExists(atPath: url.path) else {
                print("⚙️ 设置文件不存在，使用默认设置")
                return GameSettings()
            }
            
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            let settings = try decoder.decode(GameSettings.self, from: data)
            print("⚙️ 游戏设置加载成功")
            return settings
            
        } catch {
            print("❌ 加载游戏设置失败: \(error.localizedDescription)")
            return GameSettings()
        }
    }
    
    // MARK: - 清空存档
    
    func clearSaveData() {
        let playerDataURL = documentsDirectory.appendingPathComponent(playerDataFileName)
        
        do {
            if FileManager.default.fileExists(atPath: playerDataURL.path) {
                try FileManager.default.removeItem(at: playerDataURL)
                print("🗑️ 玩家存档已清空")
            }
        } catch {
            print("❌ 清空存档失败: \(error.localizedDescription)")
        }
    }
    
    func clearAllData() {
        let playerDataURL = documentsDirectory.appendingPathComponent(playerDataFileName)
        let settingsURL = documentsDirectory.appendingPathComponent(gameSettingsFileName)
        
        do {
            if FileManager.default.fileExists(atPath: playerDataURL.path) {
                try FileManager.default.removeItem(at: playerDataURL)
            }
            
            if FileManager.default.fileExists(atPath: settingsURL.path) {
                try FileManager.default.removeItem(at: settingsURL)
            }
            
            print("🗑️ 所有存档数据已清空")
        } catch {
            print("❌ 清空所有数据失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 备份和恢复
    
    func createBackup() -> Bool {
        do {
            let playerDataURL = documentsDirectory.appendingPathComponent(playerDataFileName)
            let backupURL = documentsDirectory.appendingPathComponent("player_backup.json")
            
            if FileManager.default.fileExists(atPath: playerDataURL.path) {
                try FileManager.default.copyItem(at: playerDataURL, to: backupURL)
                print("💾 创建备份成功")
                return true
            }
        } catch {
            print("❌ 创建备份失败: \(error.localizedDescription)")
        }
        return false
    }
    
    func restoreFromBackup() -> Bool {
        do {
            let backupURL = documentsDirectory.appendingPathComponent("player_backup.json")
            let playerDataURL = documentsDirectory.appendingPathComponent(playerDataFileName)
            
            if FileManager.default.fileExists(atPath: backupURL.path) {
                if FileManager.default.fileExists(atPath: playerDataURL.path) {
                    try FileManager.default.removeItem(at: playerDataURL)
                }
                try FileManager.default.copyItem(at: backupURL, to: playerDataURL)
                print("📖 从备份恢复成功")
                return true
            }
        } catch {
            print("❌ 从备份恢复失败: \(error.localizedDescription)")
        }
        return false
    }
    
    // MARK: - 存档信息
    
    func getSaveInfo() -> SaveInfo? {
        let url = documentsDirectory.appendingPathComponent(playerDataFileName)
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let modificationDate = attributes[.modificationDate] as? Date ?? Date()
            let fileSize = attributes[.size] as? Int64 ?? 0
            
            // 快速读取玩家基本信息
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            let playerName = json?["name"] as? String ?? "未知"
            let realm = json?["currentRealm"] as? String ?? "练气期"
            let level = json?["level"] as? Int ?? 1
            
            return SaveInfo(
                playerName: playerName,
                realm: realm,
                level: level,
                lastSaveDate: modificationDate,
                fileSize: fileSize
            )
            
        } catch {
            print("❌ 获取存档信息失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - 导入导出
    
    func exportSaveData() -> Data? {
        let url = documentsDirectory.appendingPathComponent(playerDataFileName)
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            print("📤 存档数据导出成功")
            return data
        } catch {
            print("❌ 导出存档数据失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    func importSaveData(_ data: Data) -> Bool {
        do {
            // 验证数据格式
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            _ = try decoder.decode(Player.self, from: data)
            
            // 保存数据
            let url = documentsDirectory.appendingPathComponent(playerDataFileName)
            try data.write(to: url)
            
            print("📥 存档数据导入成功")
            return true
            
        } catch {
            print("❌ 导入存档数据失败: \(error.localizedDescription)")
            return false
        }
    }
}

// MARK: - 存档信息结构体

struct SaveInfo {
    let playerName: String
    let realm: String
    let level: Int
    let lastSaveDate: Date
    let fileSize: Int64
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: lastSaveDate)
    }
    
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
}

// MARK: - 游戏设置结构体

struct GameSettings: Codable {
    var musicVolume: Float = 0.8
    var soundEffectVolume: Float = 0.8
    var isAutoSaveEnabled: Bool = true
    var autoSaveInterval: TimeInterval = 300 // 5分钟
    var showDamageNumbers: Bool = true
    var showCombatLog: Bool = true
    var enableHapticFeedback: Bool = true
    var graphicsQuality: GraphicsQuality = .medium
    var language: String = "zh-CN"
    
    enum GraphicsQuality: String, CaseIterable, Codable {
        case low = "低"
        case medium = "中"
        case high = "高"
        case ultra = "超高"
    }
} 