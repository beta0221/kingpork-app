# MVVM 架構實作說明

## 概述
本專案的 Home Screen 已成功實作 MVVM (Model-View-ViewModel) 架構,使用 Provider 進行狀態管理。

## 架構層級

### 1. Model Layer (資料層)
位置: `lib/models/`

- **ApiCategory** - API 分類資料模型
- **ApiProduct** - API 產品資料模型
- **CategoryWithProducts** - 分類與產品組合模型
- **BannerModel** - Banner 資料模型

### 2. Service Layer (服務層)
位置: `lib/services/`

- **LandingService** - 載入首頁資料 (banners, categories)
- **ShopService** - 商品相關 API (`getProductsByCategory`)
- **ApiClient** - HTTP 請求封裝

### 3. ViewModel Layer (視圖模型層)
位置: `lib/viewmodels/`

- **BaseViewModel** - 基礎 ViewModel,提供狀態管理
  - ViewState: `idle`, `loading`, `success`, `error`
  - 統一的錯誤處理機制

- **HomeViewModel** - Home Screen 的 ViewModel
  - 管理 banners, categories, products 資料
  - 提供 `initialize()` 初始化資料
  - 提供 `loadProductsByCategory(slug)` 切換分類
  - 提供 `refresh()` 刷新資料

### 4. View Layer (視圖層)
位置: `lib/screens/home/`

- **HomeScreen** - 主畫面
  - 使用 `Consumer<HomeViewModel>` 監聽狀態
  - 處理 loading/error/success 狀態
  - 實作下拉刷新功能

- **OffersCarousel** - Banner 輪播組件
  - 從 ViewModel 讀取 banners
  - 自動輪播功能

- **Categories** - 分類按鈕組件
  - 從 ViewModel 讀取 categories
  - 點擊分類時呼叫 `loadProductsByCategory()`

## 資料流

```
User Action (點擊分類)
    ↓
View (Categories)
    ↓
ViewModel.loadProductsByCategory(slug)
    ↓
Service (ShopService.getProductsByCategory)
    ↓
API Request
    ↓
Model (CategoryWithProducts.fromJson)
    ↓
ViewModel (更新 _products, notifyListeners)
    ↓
View (Consumer 自動重建 UI)
```

## API 整合

### Products Grid
- **資料來源**: `ShopService.getProductsByCategory(slug)`
- **預設分類**: 第一個分類 (categories[0].slug)
- **圖片 URL**: `https://stageapi.kingpork.com.tw/images/product/{image}`
- **價格邏輯**:
  - 原價: `product.price`
  - 促銷價: `product.bonus` (當 bonus < price 時)
  - 折扣百分比: `product.discountPercent`

### 分類切換
用戶點擊分類按鈕 → 呼叫 `viewModel.loadProductsByCategory(categorySlug)` → 產品列表自動更新

## 狀態管理

### ViewState 狀態
- **idle**: 閒置狀態
- **loading**: 載入中 (顯示 skeleton)
- **success**: 載入成功
- **error**: 錯誤 (顯示錯誤訊息和重試按鈕)

### Provider 設置
在 `main.dart` 中設置:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => HomeViewModel()),
  ],
  child: MaterialApp(...)
)
```

## 優勢

1. **關注點分離**: UI、業務邏輯、資料層清楚分離
2. **易於測試**: ViewModel 可獨立進行單元測試
3. **響應式 UI**: Provider 自動處理 UI 更新
4. **錯誤處理**: 統一的錯誤處理機制
5. **可維護性**: 清晰的程式碼結構,易於擴展

## 未來擴展

1. 可為其他頁面 (購物車、個人資料等) 建立對應的 ViewModel
2. 可加入 Repository 層進一步分離資料邏輯
3. 可加入 Dependency Injection (如 GetIt) 管理依賴
4. 可加入快取機制減少 API 請求
