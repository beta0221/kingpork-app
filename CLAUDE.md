# CLAUDE.md

此檔案為 Claude Code (claude.ai/code) 在此儲存庫中工作時提供指導。

## 專案概述

FlutterShop 是一個高級電子商務 UI 套件模板，擁有 100 多個畫面，用於在 Android 和 iOS 上建立電子商務應用程式。這是來自 The Flutter Way 的 UI 模板（不是完整的後端整合應用程式）。

## 開發指令

### 執行應用程式
```bash
flutter run
```

### 在特定裝置上執行
```bash
flutter devices  # 列出可用裝置
flutter run -d <device-id>
```

### 建置
```bash
flutter build apk          # Android APK
flutter build ios          # iOS（需要 macOS）
flutter build appbundle    # Android App Bundle
```

### 測試
```bash
flutter test               # 執行所有測試
flutter test test/widget_test.dart  # 執行特定測試檔案
```

### 程式碼分析
```bash
flutter analyze            # 執行靜態分析
```

### 清除建置產物
```bash
flutter clean
flutter pub get
```

## 專案架構

### 目錄結構

**lib/main.dart**：應用程式進入點，配置 MaterialApp 的路由和主題
- 使用 `router.generateRoute` 進行命名路由導航
- 支援淺色/深色主題，使用 `ThemeMode.system`
- 初始路由為引導畫面

**lib/entry_point.dart**：引導後的主導航腳手架
- 管理底部導航，包含 5 個分頁：商店（首頁）、探索、書籤、購物車、個人資料
- 使用 PageTransitionSwitcher 與 FadeThroughTransition 實現流暢的頁面切換
- 包含頂部應用程式列，帶有搜尋和通知圖示

**lib/screens/**：按功能組織的畫面級 UI 元件
- 每個畫面功能都有自己的目錄（auth、home、product、checkout 等）
- 25 個以上的畫面目錄，涵蓋完整的電子商務流程
- 主要流程：引導 → 驗證 → 首頁/探索/書籤/購物車/個人資料

**lib/components/**：可重複使用的 UI 元件
- 橫幅元件（L 和 S 變體，具有不同風格）
- 產品卡片、購物車按鈕、評論卡片、訂單狀態卡片
- 共用小工具，如 `network_image_with_loader`、`custom_modal_bottom_sheet`
- 子目錄中的列表項目和骨架載入器

**lib/route/**：導航系統
- `route_constants.dart`：所有路由名稱的字串常數（60 個以上的路由）
- `router.dart`：每個畫面的路由生成邏輯，使用 MaterialPageRoute
- `screen_export.dart`：所有畫面匯入的集中匯出檔案

**lib/theme/**：主題配置
- `app_theme.dart`：定義 `lightTheme()` 和 `darkTheme()` 方法
- 按鈕、輸入框、核取方塊、資料表格的獨立主題檔案
- 使用自訂字體：「Plus Jakarta」（主要）和「Grandis Extended」

**lib/models/**：資料模型
- `product_model.dart`：產品資料結構
- `category_model.dart`：分類資料結構

**lib/constants.dart**：全域常數
- 色彩調色板（主色、黑白變體、語義色彩）
- 排版常數
- 佈局常數（defaultPadding: 16.0、defaultBorderRadius: 12.0）
- 表單驗證器（電子郵件、需要特殊字元的密碼）
- 用於原型設計的示範產品圖片 URL

### 導航模式

此應用程式使用 Flutter 的命名路由系統：
1. 在 `route_constants.dart` 中定義路由常數
2. 在 `router.dart` 的 `generateRoute()` switch 語句中新增路由 case
3. 使用 `Navigator.pushNamed(context, routeName)` 進行導航
4. 在路由中透過 `settings.arguments` 傳遞參數

### 主題

- 兩個全面的主題（淺色/深色），涵蓋所有小工具
- 主色：`#7B61FF`（紫色）
- 深色主題使用 `#16161E` 背景
- 主題集中化且在所有元件中保持一致

### 資源組織

- **assets/images/**：一般圖片
- **assets/icons/**：SVG 圖示（使用 flutter_svg 套件）
- **assets/Illustration/**：插圖圖形
- **assets/flags/**：國旗圖片
- **assets/logo/**：應用程式標誌（Shoplon.svg）
- **assets/fonts/**：自訂字體（Plus Jakarta、Grandis Extended）

## 主要依賴項

- **flutter_svg**：圖示和標誌的 SVG 渲染
- **form_field_validator**：表單驗證工具
- **cached_network_image**：效能的圖片快取
- **flutter_rating_bar**：產品的星級評分
- **flutter_widget_from_html_core**：HTML 渲染
- **animations**：共享元素轉場（在 entry_point.dart 中使用）

## 開發注意事項

### 新增新畫面時：
1. 在適當的 `lib/screens/<feature>/` 目錄中建立畫面檔案
2. 將路由常數新增到 `route_constants.dart`
3. 在 `router.dart` 的 generateRoute switch 中新增路由 case
4. 在 `screen_export.dart` 中匯出畫面
5. 使用路由常數進行導航

### 樣式慣例：
- 使用 `constants.dart` 中的常數來設定顏色、邊距和持續時間
- 遵循現有主題結構以保持一致性
- 元件使用 Theme.of(context) 進行動態主題設定
- SVG 圖示透過 ColorFilter 配合主題感知顏色進行著色

### 這是一個 UI 模板：
- 沒有後端整合或狀態管理（如 Provider/Riverpod/Bloc）
- 全程使用靜態資料和示範 URL
- 專注於 UI/UX 模式和畫面流程，而非業務邏輯
