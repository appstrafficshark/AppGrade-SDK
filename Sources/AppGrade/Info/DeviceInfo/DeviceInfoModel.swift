
import Foundation
 
// MARK: - SendingDeviceInfoModel
struct SendingDeviceInfoModel: Codable {
    let info: MainDeviceInfo
    let environment: DeviceInfo
    
    enum CodingKeys: String, CodingKey {
        case info, environment
    }
    
}

// MARK: - MainDeviceInfo
struct MainDeviceInfo: Codable {
    let deviceModel: String
    let deviceManufacturer: String
    let screenWidth: Double
    let screenHeight: Double
    let screenScale: Double
    let screenRefreshRate: Int
    let ramTotal: UInt64
    let cpuCoreCount: Int
    let cpuArchitecture: String
    let isEmulator: Bool
    
    enum CodingKeys: String, CodingKey {
        case deviceModel = "device_model"
        case deviceManufacturer = "device_manufacturer"
        case screenWidth = "screen_width"
        case screenHeight = "screen_height"
        case screenScale = "screen_scale"
        case screenRefreshRate = "screen_refresh_rate"
        case ramTotal = "ram_total"
        case cpuCoreCount = "cpu_core_count"
        case cpuArchitecture = "cpu_architecture"
        case isEmulator = "is_emulator"
    }
    
}

// MARK: - DeviceInfo
struct DeviceInfo: Codable {
    let osVersion: String
    let ramAvailable: Int
    let batteryState: String
    let thermalState: String
    let preferredLanguages: [String]
    let localeRegion: String
    let localeLanguage: String
    let timezoneId: String
    let isVoiceOverOn: Bool
    let isBoldText: Bool
    let isReduceMotion: Bool
    let preferredContentSize: String
    let isLowPowerMode: Bool
    let uiStyle: String
    let isJailbroken: Bool 
    
    enum CodingKeys: String, CodingKey {
        case osVersion = "os_version"
        case ramAvailable = "ram_available"
        case batteryState = "battery_state"
        case thermalState = "thermal_state"
        case preferredLanguages = "preferred_languages"
        case localeRegion = "locale_region"
        case localeLanguage = "locale_language"
        case timezoneId = "timezone_id"
        case isVoiceOverOn = "is_voiceover_on"
        case isBoldText = "is_bold_text"
        case isReduceMotion = "is_reduce_motion"
        case preferredContentSize = "preferred_content_size"
        case isLowPowerMode = "is_low_power_mode"
        case uiStyle = "ui_style"
        case isJailbroken = "is_jail_broken"
    }
    
}
