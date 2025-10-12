# Fastlane Setup Guide for KP-Flutter

本文件說明如何使用 Fastlane 部署 iOS 應用程式到 TestFlight 和 App Store。

## 📋 前置需求

1. **Apple Developer 帳號** (已付費的開發者帳號 $99/年)
2. **Xcode** (最新版本)
3. **Fastlane** (已安裝 ✅)
4. **正式的 Bundle Identifier** (不能使用 `com.example.*`)
5. **App Store Connect 中已建立的 App**

## 🚀 初始設定步驟

### 步驟 1: 更新 Bundle Identifier

目前的 Bundle ID 是 `com.example.shop`，需要改成正式的 ID（例如：`com.tklab.shop` 或 `com.kingpork.shop`）

1. 在 Xcode 中開啟專案：
   ```bash
   open ios/Runner.xcworkspace
   ```

2. 選擇 Runner target → General → Bundle Identifier
3. 更改為你的正式 Bundle ID

4. 同步更新到 Fastlane 設定：
   ```bash
   # 編輯 ios/fastlane/Appfile
   # 將 app_identifier("com.example.shop") 改成你的 Bundle ID
   ```

### 步驟 2: 設定 Apple 帳號資訊

編輯 `ios/fastlane/Appfile`：

```ruby
app_identifier("com.tklab.shop") # 你的 Bundle ID

# 選項 1: 使用 Apple ID (適合個人或小團隊)
apple_id("your-email@example.com")
team_id("YOUR_TEAM_ID") # 在 https://developer.apple.com/account 找到

# 選項 2: 使用 App Store Connect API Key (推薦用於 CI/CD)
# app_store_connect_api_key(
#   key_id: "YOUR_KEY_ID",
#   issuer_id: "YOUR_ISSUER_ID",
#   key_filepath: "./AuthKey_YOUR_KEY_ID.p8"
# )
```

**如何取得 Team ID：**
1. 前往 https://developer.apple.com/account
2. 登入後點選右上角帳號
3. 在 Membership 頁面可以看到 Team ID

**如何取得 App Store Connect API Key (推薦)：**
1. 前往 https://appstoreconnect.apple.com/access/api
2. 點擊 "+" 建立新的 API Key
3. 選擇 "Admin" 或 "App Manager" 角色
4. 下載 `.p8` 檔案並放到 `ios/fastlane/` 目錄（不會被 git 追蹤）
5. 記錄 Key ID 和 Issuer ID

### 步驟 3: 設定憑證管理 (使用 Match)

Match 是 Fastlane 的憑證管理工具，可以在團隊之間同步憑證。

1. **建立私有 Git Repository 儲存憑證**
   ```bash
   # 在 GitHub/GitLab 建立一個新的私有 repo，例如：
   # https://github.com/your-org/certificates
   ```

2. **初始化 Match**
   ```bash
   cd ios
   fastlane match init
   ```
   - 選擇 git
   - 輸入 Git repo URL
   - 會建立 `ios/fastlane/Matchfile`

3. **編輯 Matchfile**
   ```ruby
   git_url("https://github.com/your-org/certificates")
   storage_mode("git")
   type("appstore")
   app_identifier("com.tklab.shop")
   username("your-email@example.com")
   ```

4. **產生憑證**
   ```bash
   cd ios
   fastlane match appstore
   fastlane match development
   ```
   - 第一次執行會要求設定密碼（用來加密憑證）
   - 團隊成員執行時使用相同密碼就能取得憑證

5. **更新 Fastfile 中的 provisioning profiles**

   編輯 `ios/fastlane/Fastfile`，在 `build_app` 的 `export_options` 中加入：
   ```ruby
   export_options: {
     provisioningProfiles: {
       "com.tklab.shop" => "match AppStore com.tklab.shop"
     }
   }
   ```

### 步驟 4: 在 App Store Connect 建立 App

1. 前往 https://appstoreconnect.apple.com
2. 點擊 "我的 App" → "+" → "新增 App"
3. 填寫資訊：
   - 平台：iOS
   - 名稱：你的 App 名稱
   - 主要語言：繁體中文或英文
   - Bundle ID：選擇你剛才建立的 Bundle ID
   - SKU：可以使用 Bundle ID 作為 SKU

## 📦 使用 Fastlane 部署

### 部署到 TestFlight (Beta 測試)

```bash
cd ios
fastlane beta
```

這個指令會：
1. ✅ 自動增加 build number
2. ✅ 執行 Flutter clean 和 build
3. ✅ 建置並簽名 iOS app
4. ✅ 上傳到 TestFlight
5. ✅ Commit version bump
6. ✅ 建立 git tag
7. ✅ Push 到遠端 repo

**首次執行可能會遇到的問題：**
- 需要輸入 Apple ID 密碼
- 需要處理雙重驗證 (2FA)
- 可能需要接受協議：前往 https://developer.apple.com/account 和 https://appstoreconnect.apple.com 接受新協議

### 部署到 App Store (正式版)

```bash
cd ios
fastlane release
```

這個指令會：
1. ✅ 自動增加 build number
2. ✅ 執行 Flutter clean 和 build
3. ✅ 建置並簽名 iOS app
4. ✅ 上傳到 App Store Connect
5. ✅ Commit version bump
6. ✅ 建立 git tag
7. ✅ Push 到遠端 repo

**注意：**
- 預設不會自動提交審核 (`submit_for_review: false`)
- 你需要手動到 App Store Connect 提交審核
- 如果要自動提交審核，可以在 Fastfile 中改成 `submit_for_review: true`

### 其他實用指令

**只建置不上傳：**
```bash
cd ios
fastlane build_only
```

**更新版本號：**
```bash
cd ios
fastlane bump_version version:1.2.0
```

**設定憑證：**
```bash
cd ios
fastlane certificates
```

## 🔧 進階設定

### 環境變數設定 (.env 檔案)

你可以建立環境變數檔案來儲存敏感資訊：

```bash
# 建立 ios/fastlane/.env.default
touch ios/fastlane/.env.default
```

內容範例：
```bash
FASTLANE_USER="your-email@example.com"
FASTLANE_TEAM_ID="YOUR_TEAM_ID"
FASTLANE_ITC_TEAM_ID="YOUR_APP_STORE_CONNECT_TEAM_ID"
MATCH_PASSWORD="your-match-password"
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="your-app-specific-password"
```

這些檔案已經在 `.gitignore` 中，不會被 commit。

### 自動化建置 (CI/CD)

如果要在 CI/CD 環境（如 GitHub Actions、GitLab CI）中使用：

1. **使用 App Store Connect API Key** (而不是 Apple ID)
2. **設定環境變數**
3. **使用 Match 的 readonly 模式**

GitHub Actions 範例：
```yaml
name: Deploy to TestFlight

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Deploy to TestFlight
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD: ${{ secrets.FASTLANE_PASSWORD }}
        run: |
          cd ios
          fastlane beta
```

## 📝 常見問題

### Q: 執行 fastlane 時要求登入 Apple ID
A: 這是正常的。首次執行時需要登入並通過雙重驗證。建議使用 App Store Connect API Key 來避免每次都要登入。

### Q: "No signing certificate found"
A: 執行 `fastlane match appstore` 來產生憑證。

### Q: "Provisioning profile doesn't match"
A: 確認 Fastfile 中的 provisioning profile 名稱正確，格式為 `match AppStore YOUR_BUNDLE_ID`。

### Q: Build number 衝突
A: 如果 App Store Connect 已經有相同的 build number，會上傳失敗。執行 `fastlane beta` 會自動增加 build number。

### Q: 想要跳過 git 檢查
A: 設定環境變數 `SKIP_GIT_CHECK=true`：
```bash
SKIP_GIT_CHECK=true fastlane beta
```

## 📚 參考資源

- [Fastlane 官方文件](https://docs.fastlane.tools/)
- [Match 文件](https://docs.fastlane.tools/actions/match/)
- [App Store Connect API](https://developer.apple.com/app-store-connect/api/)
- [Flutter iOS 部署指南](https://docs.flutter.dev/deployment/ios)

## 🎯 下一步

1. ✅ 更新 Bundle Identifier
2. ✅ 設定 Apple 帳號資訊（Appfile）
3. ✅ 設定 Match 憑證管理
4. ✅ 在 App Store Connect 建立 App
5. ✅ 執行第一次 `fastlane beta` 測試

完成這些步驟後，你就可以用一行指令部署到 TestFlight 和 App Store 了！🚀
