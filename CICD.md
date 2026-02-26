# TK-App CI/CD 部署文件

## 📋 分支與環境對應

| 分支 | 環境 | 自動部署 | URL |
|------|------|---------|-----|
| `feature/*` | Local | ❌ 僅測試 | - |
| `develop` | Stage | ⚠️ 手動觸發 | https://tk-app-testing.web.app |
| `main` | Production | ⚠️ 手動觸發 | *待設定* |

## 🔧 GitLab CI/CD 變數設定

前往：https://gitlab.ton8tenacious.com/kings/tk-app/-/settings/ci_cd

### Firebase 變數（共用）

| Key | Value | Protected | Masked |
|-----|-------|-----------|--------|
| `FIREBASE_TOKEN` | `1//0xxx...` | ✅ | ✅ |

### Production 變數（待設定）

| Key | Value | Protected | Masked | 說明 |
|-----|-------|-----------|--------|------|
| `PROD_URL` | `https://tk-app.web.app` | ✅ | ❌ | Production URL |

## 🚀 Pipeline 流程

```
┌──────────────┐
│ feature/*    │ → Test only (本地開發)
└──────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ develop      │ ──→ │ Test         │ ──→ │ Build Stage  │ ──→ │ Deploy Stage │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
                                                                      (手動觸發)

┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ main         │ ──→ │ Test         │ ──→ │ Build Prod   │ ──→ │ Deploy Prod  │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
                                                                      (手動觸發)
```

## 📝 部署步驟

### 部署到 Stage

1. 將代碼合併到 `develop` 分支
2. GitLab 自動執行 Test 和 Build
3. 前往 GitLab Pipeline 頁面
4. 點擊 **"Deploy Stage"** 按鈕
5. 確認部署到 Firebase Hosting
6. 訪問 https://tk-app-testing.web.app 驗證

### 部署到 Production

1. 將代碼合併到 `main` 分支
2. GitLab 自動執行 Test 和 Build
3. 前往 GitLab Pipeline 頁面
4. 點擊 **"Deploy Production"** 按鈕
5. ⚠️ **確認無誤後**再執行
6. 確認部署完成

## 🔍 Pipeline 階段說明

### Test Stage
- 檢查 Flutter 環境
- 執行 `flutter analyze`
- 驗證依賴安裝
- 執行於所有分支

### Build Stage
- Flutter pub get
- 建置 Web 版本
- 產生 `build/web/` artifacts
- 執行於 `develop` 和 `main`

### Deploy Stage
- 使用 Firebase CLI 部署
- 上傳到 Firebase Hosting
- **手動觸發**（安全起見）

## 🔥 Firebase 配置

### Stage 環境
- **Project ID：** tk-app-testing
- **Hosting URL：** https://tk-app-testing.web.app

### Production 環境
*待設定*

需要在 `.firebaserc` 添加 production 專案：

```json
{
  "projects": {
    "default": "tk-app-testing",
    "production": "tk-app-production"
  }
}
```

## 📱 Flutter 環境

- **Flutter：** 3.41.2
- **Dart：** 3.11.0
- **平台：** Web (Chrome)
- **建置命令：** `flutter build web --release --no-tree-shake-icons`

## 📊 監控與日誌

### Pipeline 監控
- **URL：** https://gitlab.ton8tenacious.com/kings/tk-app/-/pipelines

### Firebase Hosting 監控
- **Console：** https://console.firebase.google.com/project/tk-app-testing/hosting

## 🛠️ 本地測試

```bash
cd ~/.openclaw/workspace/tk-app

# 安裝依賴
flutter pub get

# 執行分析
flutter analyze

# 建置 Web
flutter build web --release

# 本地預覽
cd build/web
python3 -m http.server 8080
# 訪問 http://localhost:8080
```

## 🔐 安全性

1. ✅ Firebase Token 儲存在 GitLab CI/CD 變數
2. ✅ Production 部署需要手動確認
3. ✅ 使用 Protected 和 Masked 變數
4. ✅ Token 不會顯示在日誌中

## 📞 緊急回滾

Firebase Hosting 支援快速回滾：

1. 前往 [Firebase Console](https://console.firebase.google.com/project/tk-app-testing/hosting)
2. 選擇 **Hosting**
3. 查看 **Release history**
4. 點擊之前的版本
5. 選擇 **Roll back**

或使用 CLI：

```bash
# 查看部署歷史
firebase hosting:channel:list

# 回滾到特定版本
firebase hosting:clone <source-version> <target-version>
```

## 🎯 下一步

1. ⚠️ **建立 Production Firebase 專案**
2. ⚠️ **設定 Production 環境變數**
3. ✅ 測試 Stage 環境部署
4. ✅ 設定 Firebase Analytics
5. ✅ 設定部署通知（Telegram/Email）
6. ✅ 設定 Custom Domain（如果需要）

## 🌐 Custom Domain 設定

如果需要設定自訂網域（例如：app.kingpork.com.tw）：

1. 前往 Firebase Console → Hosting
2. 點擊 **Add custom domain**
3. 輸入網域名稱
4. 依照指示設定 DNS 記錄
5. 等待 SSL 憑證自動配置
