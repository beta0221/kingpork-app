# Phase 1.3 - API Layer Update 完成總結

## 完成日期
2025-01-06

## 實作內容

### 1. 擴充 FlavorConfig (`lib/config/flavor_config.dart`)

新增了以下配置項目，涵蓋 tklabApp 所需的所有環境配置：

- **WebSocket URL** (`wssUrl`)：即時聊天使用的 WebSocket 連線位址
- **Firebase App Link** (`firebaseAppLink`)：Firebase Dynamic Links 的連結前綴
- **Matomo URL** (`matomoUrl`)：分析追蹤服務的端點
- **Matomo Site ID** (`matomoSiteId`)：Matomo 網站識別碼

#### 新增便利方法：
- `apiUrl`：取得完整的 API URL（`baseUrl/api/next`）
- `appApiUrl`：取得舊版 APP API URL（`baseUrl/api/app`）

#### 配置值（從 tklabApp 移植）：

**DEV 環境：**
- Base URL: `https://rd.tklab.com.tw`
- OneSignal ID: `2780fb32-fc29-41be-9c0b-b43131b71b65`
- WSS URL: `wss://rd.tklab.com.tw/wss`
- Firebase Link: `https://tklab.page.link`
- Matomo: `https://rd.tklab.com.tw/matomo/matomo.php`

**UAT 環境：**
- Base URL: `https://test.tklab.com.tw`
- OneSignal ID: `3685eb59-ed9a-45a2-8979-b9122a9f0e92`
- WSS URL: `wss://test.tklab.com.tw/wss`
- Firebase Link: `https://tktest.page.link`
- Matomo: 無（空字串）

**PROD 環境：**
- Base URL: `https://www.tklab.com.tw`
- OneSignal ID: `94fe3582-4d7e-40e6-8b03-127de7cacff7`
- WSS URL: `wss://www.tklab.com.tw/wss`
- Firebase Link: `https://tkapp.page.link`
- Matomo: `https://ga.tklab.com.tw/matomo.php`

### 2. 更新 ApiEndpoints (`lib/services/api/api_endpoints.dart`)

- ✅ 引入 `FlavorConfig` 依賴
- ✅ 將硬編碼的 `baseUrl` 改為動態從 `FlavorConfig.instance.baseUrl` 取得
- ✅ 更新 `apiPrefix` 為 `/api/next`（與 tklabApp 一致）
- ✅ `baseUrl` 現在會根據當前運行的 Flavor 自動切換

### 3. 增強 TokenManager (`lib/utils/token_manager.dart`)

新增功能：
- ✅ **Refresh Token 支援**：新增 `saveRefreshToken()` 和 `getRefreshToken()` 方法
- ✅ **Token 過期檢查**：實作 `isTokenExpired()` 方法，支援提前 5 分鐘判定過期
- ✅ **時間戳記錄**：儲存 token 儲存時間 (`tokenSavedAt`)
- ✅ **智能登入檢查**：`isLoggedIn()` 現在會檢查 token 是否過期
- ✅ **完整清除**：`clearTokens()` 現在清除所有 token 相關資料（包括 refresh token 和時間戳）

### 4. ApiClient 驗證

- ✅ ApiClient 已正確使用 `ApiEndpoints.buildUrl()`
- ✅ ApiClient 已正確使用 `TokenManager` 進行認證
- ✅ 環境切換會自動反映在所有 API 請求中

### 5. 程式碼品質改善

- ✅ 修復 `main_dev.dart`、`main_uat.dart`、`main_prod.dart` 中未使用的 import
- ✅ Flutter analyze 警告從 17 個減少到 14 個（剩餘為 info 級別建議）

### 6. 測試覆蓋

創建了三個測試檔案，總共 19 個測試案例，全部通過：

#### `test/config/flavor_config_test.dart` (6 tests)
- DEV/UAT/PROD 環境配置驗證
- OneSignal App ID 驗證
- Firebase App Link 驗證
- Matomo URL 驗證

#### `test/services/api_endpoints_test.dart` (4 tests)
- 各環境的 Base URL 驗證
- `buildUrl()` 方法驗證
- 動態端點建構驗證

#### `test/utils/token_manager_test.dart` (9 tests)
- Token 儲存與讀取
- Token 資料完整性
- 登入狀態檢查
- Token 過期檢查
- Token 清除功能

## 執行結果

```bash
flutter test test/config/flavor_config_test.dart test/services/api_endpoints_test.dart test/utils/token_manager_test.dart
```

**結果：19/19 測試通過 ✅**

## API Layer 架構圖

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                        │
│              (ViewModels, Services, Screens)                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                      ApiClient                              │
│  • HTTP Methods (GET/POST/PUT/DELETE)                       │
│  • Request/Response Handling                                │
│  • Error Handling                                           │
│  • Token Management Integration                             │
└────────┬────────────────────────────────────┬───────────────┘
         │                                    │
         ▼                                    ▼
┌─────────────────────┐          ┌─────────────────────────┐
│   ApiEndpoints      │          │    TokenManager         │
│  • buildUrl()       │          │  • saveTokenData()      │
│  • Auth endpoints   │          │  • getAccessToken()     │
│  • Shop endpoints   │          │  • isTokenExpired()     │
│  • Cart endpoints   │          │  • clearTokens()        │
│  • Order endpoints  │          └─────────┬───────────────┘
└─────────┬───────────┘                    │
          │                                │
          ▼                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     FlavorConfig                            │
│  • baseUrl (根據 dev/uat/prod 自動切換)                     │
│  • oneSignalAppId                                           │
│  • wssUrl                                                   │
│  • firebaseAppLink                                          │
│  • matomoUrl                                                │
│  • apiUrl / appApiUrl (便利方法)                            │
└─────────────────────────────────────────────────────────────┘
```

## 使用範例

### 1. 在不同環境中運行應用程式

```bash
# DEV 環境 - 自動使用 https://rd.tklab.com.tw
flutter run -d <device-id> -t lib/main_dev.dart

# UAT 環境 - 自動使用 https://test.tklab.com.tw
flutter run -d <device-id> -t lib/main_uat.dart

# PROD 環境 - 自動使用 https://www.tklab.com.tw
flutter run -d <device-id> -t lib/main_prod.dart
```

### 2. 在程式碼中使用 API Layer

```dart
import 'package:tklab_ec_v2/services/api/api_client.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';
import 'package:tklab_ec_v2/utils/token_manager.dart';

// 初始化 API Client
final apiClient = ApiClient();

// 呼叫 API（不需認證）
try {
  final categories = await apiClient.get(
    ApiEndpoints.categories,
    requiresAuth: false,
  );
  print('Categories: $categories');
} catch (e) {
  print('Error: $e');
}

// 呼叫需要認證的 API
try {
  final userData = await apiClient.get(
    ApiEndpoints.user,
    requiresAuth: true, // 自動附加 Bearer token
  );
  print('User: $userData');
} on UnauthorizedException {
  // Token 無效或過期，導向登入頁面
  print('請重新登入');
} catch (e) {
  print('Error: $e');
}
```

### 3. Token 管理

```dart
import 'package:tklab_ec_v2/utils/token_manager.dart';

final tokenManager = TokenManager();

// 儲存登入 token
await tokenManager.saveTokenData(
  accessToken: 'your_access_token',
  refreshToken: 'your_refresh_token',
  tokenType: 'Bearer',
  expiresIn: 3600, // 1 小時
);

// 檢查登入狀態（自動檢查過期）
final isLoggedIn = await tokenManager.isLoggedIn();

// 登出
await tokenManager.clearTokens();
```

## 與 tklabApp 的差異

| 項目 | tklabApp | tklabAppV2 |
|------|----------|------------|
| 環境配置 | `ServiceSet.flavor` enum | `FlavorConfig.initialize(flavor:)` |
| 環境切換 | 修改程式碼後重新編譯 | 執行不同的入口點（main_dev/uat/prod.dart） |
| API Base URL | 硬編碼在 service_url.dart | 動態從 FlavorConfig 取得 |
| Token 管理 | 存在 HomeStatic.userToken | TokenManager 類別（支援過期檢查） |
| API Client | 自訂 getApiNormal() | 標準化的 ApiClient 類別 |

## 後續步驟

Phase 1.3 已完成！根據 TKLABAPPV2_MIGRATION_PLAN.md，下一個階段是：

**Phase 2 - Core Architecture Migration**
- 創建 ViewModels（HomeViewModel, CartViewModel, MemberViewModel 等）
- 遷移 service 層
- 創建 model 類別
- 實作 Provider 註冊

## 驗證檢查清單

- ✅ FlavorConfig 包含所有必要的環境配置
- ✅ ApiEndpoints 根據 Flavor 動態切換 Base URL
- ✅ TokenManager 支援 token 過期檢查和刷新
- ✅ ApiClient 正確整合 TokenManager 和 ApiEndpoints
- ✅ 所有三個 Flavor（dev/uat/prod）可以正常運行
- ✅ 測試覆蓋核心功能（19/19 通過）
- ✅ 程式碼品質良好（14 個 info 級別警告，無 error 阻礙開發）

---

**Phase 1.3 狀態：✅ 完成**
