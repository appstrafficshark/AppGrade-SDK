
import UIKit
import Darwin

// MARK: - DeviceInfoServiceProtocol
protocol DeviceInfoServiceProtocol {
    func collect() async -> SendingDeviceInfoModel
}

// MARK: - DeviceInfoService
final class DeviceInfoService: DeviceInfoServiceProtocol {
    
    func collect() async -> SendingDeviceInfoModel {
        let mainDeviceInfo: MainDeviceInfo = await .init(deviceModel: getDeviceModel(),
                                                   deviceManufacturer: getDeviceManufacturer(),
                                                   screenWidth: UIScreen.main.nativeBounds.width,
                                                   screenHeight: UIScreen.main.nativeBounds.height,
                                                   screenScale: UIScreen.main.scale,
                                                   screenRefreshRate: UIScreen.main.maximumFramesPerSecond,
                                                   ramTotal: ProcessInfo.processInfo.physicalMemory,
                                                   cpuCoreCount: ProcessInfo.processInfo.processorCount,
                                                   cpuArchitecture: getCPUArchitecture(),
                                                   isEmulator: isSimulator())
        let deviceInfo: DeviceInfo = await .init(osVersion: UIDevice.current.systemVersion,
                                           ramAvailable: getRamAvailable(),
                                           batteryState: getBatteryState(),
                                           thermalState: getThermalState(),
                                           preferredLanguages: Locale.preferredLanguages,
                                           localeRegion: Locale.current.regionCode ?? "unknown",
                                           localeLanguage: Locale.current.languageCode ?? "unknown",
                                           timezoneId: TimeZone.current.identifier,
                                           isVoiceOverOn: UIAccessibility.isVoiceOverRunning,
                                           isBoldText: UIAccessibility.isBoldTextEnabled,
                                           isReduceMotion: UIAccessibility.isReduceMotionEnabled,
                                           preferredContentSize: UIApplication.shared.preferredContentSizeCategory.rawValue,
                                           isLowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled,
                                           uiStyle: getUIStyle(),
                                           isJailbroken: isJailbroken())
        return .init(info: mainDeviceInfo, environment: deviceInfo)
    }
    
}

private extension DeviceInfoService {
    
    func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { id, element in
            guard let value = element.value as? Int8, value != 0 else { return id }
            return id + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    func getDeviceManufacturer() -> String {
        return "Apple"
    }

    func getCPUArchitecture() -> String {
        #if arch(arm64)
        return "arm64"
        #elseif arch(x86_64)
        return "x86_64"
        #else
        return "unknown"
        #endif
    }

    func getBatteryState() -> String {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        switch UIDevice.current.batteryState {
        case .charging: return "charging"
        case .full: return "full"
        case .unplugged: return "unplugged"
        default: return "unknown"
        }
    }

    func getThermalState() -> String {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: return "nominal"
        case .fair: return "fair"
        case .serious: return "serious"
        case .critical: return "critical"
        @unknown default: return "unknown"
        }
    }

    func getUIStyle() -> String {
        let style = UIScreen.main.traitCollection.userInterfaceStyle
        
        switch style {
        case .dark: return "dark"
        case .light: return "light"
        default: return "unspecified"
        }
    }

    func isJailbroken() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #endif
        
        let paths = [
            "/Applications/Cydia.app",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt"
        ]
        
        return paths.contains { FileManager.default.fileExists(atPath: $0) }
    }

    func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    func getRamAvailable() -> Int {
        return os_proc_available_memory()
    }
    
}



//[AppGradeSDK] --- Device info: DeviceInfo(deviceModel: "iPhone15,2", deviceManufacturer: "Apple", osVersion: "26.2", screenWidth: 393.0, screenHeight: 852.0, screenScale: 3.0, screenRefreshRate: 120.0, ramTotal: 5937381376, ramAvailable: nil, cpuCoreCount: 6, cpuArchitecture: "arm64", batteryState: "unplugged", thermalState: "nominal", preferredLanguages: ["ru-BY", "en-BY", "ja-BY", "it-BY", "ko-BY", "uk-BY", "fr-BY", "tr-BY", "ro-BY", "pt-BR", "ar-BY", "de-BY", "es-BY", "th-BY", "zh-Hans-BY", "vi-BY", "hi-BY", "pl-BY"], localeRegion: "BY", localeLanguage: "en", timezoneId: "Europe/Minsk", isVoiceOverOn: false, isBoldText: false, isReduceMotion: false, preferredContentSize: "UICTContentSizeCategoryL", isLowPowerMode: false, uiStyle: "dark", isJailbroken: false, isEmulator: false)

