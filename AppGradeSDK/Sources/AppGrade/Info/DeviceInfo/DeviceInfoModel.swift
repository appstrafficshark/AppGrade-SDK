
import Foundation

struct DeviceInfo: Codable {
    let deviceModel: String
    let deviceManufacturer: String
    let osVersion: String
    
    let screenWidth: Double
    let screenHeight: Double
    let screenScale: Double
    let screenRefreshRate: Int
    
    let ramTotal: UInt64
    let ramAvailable: UInt64? // ⛔️
    
    let cpuCoreCount: Int
    let cpuArchitecture: String
    
    let batteryState: String
    let thermalState: String
    
    let preferredLanguages: [String]
    let localeRegion: String // ⚠️
    let localeLanguage: String
    let timezoneId: String
    
    let isVoiceOverOn: Bool
    let isBoldText: Bool
    let isReduceMotion: Bool
    let preferredContentSize: String
    
    let isLowPowerMode: Bool
    let uiStyle: String
    
    let isJailbroken: Bool  // ⚠️
    let isEmulator: Bool
}

//Установка:
//device_model
//device_manufacturer
//screen_width
//screen_height
//screen_scale
//screen_refresh_rate
//ram_total
//cpu_core_count
//cpu_architecture
//is_emulator
//
//----
//
//Каждый запуск
//os_version
//ram_available
//battery_state
//thermal_state
//preferred_languages
//locale_region
//locale_language
//timezone_id
//is_voiceover_on
//is_bold_text
//is_reduce_motion
//preferred_content_size
//is_low_power_mode
//ui_style
//is_jailbroken

