
# 🚀 AppGrade.pro

**Lightweight iOS SDK for analytics, attribution, subscriptions, and user behavior tracking.**

AppGrade.pro helps you understand your users by collecting **device, network, attribution, receipt, and session data** — and sending it to backend in a clean, structured way.

---

## ✨ What AppGrade.pro does

AppGrade.pro collects and sends:

- 📱 Device information (model, OS, app version)
- 🌐 Network information (carrier, connection type)
- 🔗 Attribution data (install source, campaign tracking)
- 🧾 Receipt information (IAP & subscriptions)
- ⏱ Session tracking (app usage duration, foreground time)
- 📊 Analytics events (custom tracking)

All data is designed for **server-side processing and validation**.

---

## 🧠 Why AppGrade.pro exists

Most analytics SDKs are:

- Too heavy
- Locked into ecosystems
- Expensive or limited
- Hard to extend for custom backend logic

AppGrade.pro is built for developers who want:

- Full control over data
- Server-first architecture
- Lightweight iOS integration
- Flexible analytics pipeline

---

## ⚙️ Installation

### Swift Package Manager

**In Xcode:** File → Add Package Dependencies… and paste the repository URL:

```
https://github.com/appstrafficshark/AppGrade-SDK.git
```

Then add the `AppGradeSDK` product to your app target.

**Or in `Package.swift`:**

```swift
dependencies: [
    .package(url: "https://github.com/appstrafficshark/AppGrade-SDK.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "AppGradeSDK", package: "AppGrade-SDK")
        ]
    )
]
```


---

## 🚀 Quick Start

```swift
import AppGrade

AppGrade.shared.configure(
    apiKey: "YOUR_API_KEY",
    enableLogging: true
)
```

## 🔗 Attribution

### Correct usage

```swift
import AppTrackingTransparency

func requestTrackingAndUpdateAttribution() async {
    guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
    let _ = await ATTrackingManager.requestTrackingAuthorization()
    AppGrade.shared.updateAttributionInfo()
}
```
