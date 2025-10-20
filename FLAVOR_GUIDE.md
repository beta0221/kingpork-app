# Flutter Flavors 使用指南

本專案使用 Flutter Flavors 來管理不同環境（dev/uat/prod）的配置。

---

## 🌍 環境配置

| 環境 | Flavor | Base URL | 說明 | Banner 顏色 |
|------|--------|----------|------|-------------|
| **開發環境** | `dev` | https://rd.tklab.com.tw | 用於本地開發和測試 | 🔴 紅色 |
| **UAT 環境** | `uat` | https://test.tklab.com.tw | 用於 UAT 測試 | 🟠 橘色 |
| **正式環境** | `prod` | https://www.tklab.com.tw | 正式環境 | 無 Banner |

---

## 📱 運行指令

### iOS 模擬器

```bash
# 開發環境
flutter run -d <device-id> -t lib/main_dev.dart

# UAT 環境
flutter run -d <device-id> -t lib/main_uat.dart

# 正式環境
flutter run -d <device-id> -t lib/main_prod.dart
```

### Android 模擬器/實機

```bash
# 開發環境
flutter run -d <device-id> --flavor dev -t lib/main_dev.dart

# UAT 環境
flutter run -d <device-id> --flavor uat -t lib/main_uat.dart

# 正式環境
flutter run -d <device-id> --flavor prod -t lib/main_prod.dart
```

---

## 🏗️ 建置指令

### Android

```bash
# 開發環境 APK
flutter build apk --flavor dev -t lib/main_dev.dart

# UAT 環境 APK
flutter build apk --flavor uat -t lib/main_uat.dart

# 正式環境 App Bundle
flutter build appbundle --flavor prod -t lib/main_prod.dart
```

### iOS

```bash
# 開發環境
flutter build ios --flavor dev -t lib/main_dev.dart

# UAT 環境
flutter build ios --flavor uat -t lib/main_uat.dart

# 正式環境
flutter build ios --flavor prod -t lib/main_prod.dart
```

---

## 🔧 配置檔案說明

### 1. Flavor 配置 (`lib/config/flavor_config.dart`)

定義了三個環境的配置：
- Base URL
- OneSignal App ID
- 環境判斷方法

### 2. 入口點

- `lib/main_dev.dart` - 開發環境入口
- `lib/main_uat.dart` - UAT 環境入口
- `lib/main_prod.dart` - 正式環境入口
- `lib/main.dart` - 預設入口（開發時使用）

### 3. Android 配置 (`android/app/build.gradle.kts`)

定義了三個 Product Flavors：
- `dev` - Application ID: `com.tklab.ec.v2.dev`
- `uat` - Application ID: `com.tklab.ec.v2.uat`
- `prod` - Application ID: `com.tklab.ec.v2`

---

## 🎯 使用範例

### 在代碼中使用 Flavor 配置

```dart
import 'package:tklab_ec_v2/config/flavor_config.dart';

// 取得當前環境配置
final config = FlavorConfig.instance;

// 取得 Base URL
String baseUrl = config.baseUrl;

// 判斷環境
if (config.isDev) {
  print('開發環境');
} else if (config.isUat) {
  print('UAT 環境');
} else if (config.isProd) {
  print('正式環境');
}

// 取得環境名稱
String envName = config.name; // "DEV", "UAT", or "PROD"
String displayName = config.displayName; // "🔧 開發環境", "🧪 測試環境", or "🚀 正式環境"
```

---

## 📝 環境識別

### Debug Banner
- **DEV 環境**: 右上角顯示紅色 Banner "🔧 開發環境"
- **UAT 環境**: 右上角顯示橘色 Banner "🧪 測試環境"
- **PROD 環境**: 無 Banner

### App Title
- **DEV**: "TKLab EC V2 - DEV"
- **UAT**: "TKLab EC V2 - UAT"
- **PROD**: "TKLab EC V2 - PROD"

### App Name (Android)
- **DEV**: "TKLab V2 DEV"
- **UAT**: "TKLab V2 UAT"
- **PROD**: "TKLab V2"

---

## ⚙️ 設定 OneSignal App ID

在 `lib/config/flavor_config.dart` 中更新 OneSignal App ID：

```dart
case Flavor.dev:
  _instance = FlavorConfig._(
    // ...
    oneSignalAppId: 'YOUR_DEV_ONESIGNAL_APP_ID', // ← 在這裡更新
  );

case Flavor.uat:
  _instance = FlavorConfig._(
    // ...
    oneSignalAppId: 'YOUR_UAT_ONESIGNAL_APP_ID', // ← 在這裡更新
  );

case Flavor.prod:
  _instance = FlavorConfig._(
    // ...
    oneSignalAppId: 'YOUR_PROD_ONESIGNAL_APP_ID', // ← 在這裡更新
  );
```

---

## 🐛 常見問題

### Q: 如何快速切換環境？
A: 只需要改變運行命令的 `-t` 參數即可：
```bash
flutter run -d <device-id> -t lib/main_dev.dart  # DEV
flutter run -d <device-id> -t lib/main_uat.dart  # UAT
flutter run -d <device-id> -t lib/main_prod.dart # PROD
```

### Q: Android 為什麼需要 --flavor 參數？
A: Android 使用 Product Flavors 來管理不同環境的建置變體，所以需要額外指定 `--flavor` 參數。

### Q: 可以同時安裝多個環境的 App 嗎？
A: 可以！不同環境有不同的 Application ID，所以可以同時安裝在同一台裝置上。

### Q: 如何在 CI/CD 中使用？
A: 在 CI/CD 腳本中使用對應的建置指令：
```bash
# 例如 GitHub Actions
flutter build appbundle --flavor prod -t lib/main_prod.dart
```

---

## 📚 相關文件

- [TKLABAPPV2_MIGRATION_PLAN.md](TKLABAPPV2_MIGRATION_PLAN.md) - 完整遷移計畫
- [CLAUDE.md](CLAUDE.md) - 專案架構說明

---

**版本**: 1.0
**更新日期**: 2025-01-06
