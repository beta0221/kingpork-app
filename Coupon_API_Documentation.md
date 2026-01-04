# 優惠券系統 API 文件

## 概述

本文檔說明優惠券系統的會員端 API 使用方式。所有 API 都需要會員登入認證（使用 Session 認證）。

## 認證方式

所有優惠券相關 API 都需要會員登入，使用 Laravel Session 認證：
- 需要在請求中包含 Session Cookie
- 使用 `credentials: 'include'` 確保 Cookie 被發送

---

## API 端點總覽

| 端點 | 方法 | 說明 | 認證 |
|------|------|------|------|
| `/api/coupon/check-auto-grant` | GET | 檢查並自動發放優惠券 | 需要 |
| `/api/coupon/claim/{couponId}` | GET | 領取優惠券（透過優惠券 ID） | 需要 |
| `/api/coupon/claim-by-code/{code}` | GET | 透過序號領取優惠券 | 需要 |
| `/api/coupon/list` | GET | 取得登入自行領取的優惠券列表 | 需要 |
| `/api/coupon/auto-grant-list` | GET | 取得登入自動送的優惠券列表 | 需要 |
| `/api/coupon/my-coupons` | GET | 取得我的優惠券（已領取） | 需要 |
| `/api/coupon/use` | POST | 使用優惠券 | 需要 |

---

## API 詳細說明

### 1. 檢查並自動發放優惠券

**端點**: `GET /api/coupon/check-auto-grant`

**說明**: 前端在 App 啟動或網頁載入時呼叫，系統會自動檢查並發放符合條件的「登入自動送」優惠券（`distribution_method=1`）。

**認證**: 需要會員登入（`auth:member`）

**請求範例**:
```javascript
fetch('/api/coupon/check-auto-grant', {
    method: 'GET',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' }
})
```

**成功回應** (HTTP 200):
```json
{
  "s": 1,
  "msg": "已自動發放 2 張優惠券",
  "data": {
    "granted_coupons": [
      {
        "coupon_id": 1,
        "title": "新會員歡迎禮",
        "redemption_id": 123,
        "redemption_at": "2025-01-15 10:30:00"
      },
      {
        "coupon_id": 2,
        "title": "每日登入禮",
        "redemption_id": 124,
        "redemption_at": "2025-01-15 10:30:00"
      }
    ],
    "granted_count": 2
  }
}
```

**成功回應（沒有可發放的優惠券）** (HTTP 200):
```json
{
  "s": 1,
  "msg": "目前沒有可自動發放的優惠券",
  "data": {
    "granted_coupons": [],
    "granted_count": 0
  }
}
```

**未登入回應** (HTTP 200):
```json
{
  "s": 1,
  "msg": "未登入，無需檢查自動送優惠券",
  "data": {
    "granted_coupons": [],
    "granted_count": 0
  }
}
```

**錯誤回應** (HTTP 404):
```json
{
  "s": 0,
  "msg": "會員資料不存在"
}
```

**使用時機**:
- App 啟動時
- 網頁載入時
- 不需要真的登入動作，只要已登入狀態即可

**注意事項**:
- 建議加入 debounce 機制，避免短時間內重複呼叫
- 系統會自動檢查避免重複發放

---

### 2. 領取優惠券（透過優惠券 ID）

**端點**: `GET /api/coupon/claim/{couponId}`

**說明**: 會員自行領取優惠券（`distribution_method=2` 的優惠券）。

**認證**: 需要會員登入（`auth:member`）

**路徑參數**:
- `couponId` (必填): 優惠券 ID

**請求範例**:
```javascript
fetch('/api/coupon/claim/1', {
    method: 'GET',
    credentials: 'include'
})
```

**成功回應** (HTTP 200):
```json
{
  "s": 1,
  "msg": "優惠券領取成功",
  "data": {
    "redemption_id": 123,
    "coupon_id": 1,
    "redemption_at": "2025-01-15 10:30:00"
  }
}
```

**錯誤回應** (HTTP 400):
```json
{
  "s": 0,
  "msg": "優惠券領取失敗，可能已達領取次數限制、不符合資格或優惠券已失效"
}
```

**錯誤回應** (HTTP 401):
```json
{
  "s": 0,
  "msg": "請先登入會員"
}
```

**檢查項目**:
- 優惠券狀態（必須啟用）
- 活動時間範圍
- 領取時間範圍
- 會員等級限制
- 領取次數限制

---

### 3. 透過序號領取優惠券

**端點**: `GET /api/coupon/claim-by-code/{code}`

**說明**: 會員透過優惠券序號領取優惠券。此 API 主要用於「行銷活動」類型的優惠券，支援分享連結領取功能。系統會先從 `coupons.code` 查詢，如果找不到則從 `coupon_codes` 表查詢（批次發碼模式）。

**認證**: 需要會員登入（`auth:member`）

**路徑參數**:
- `code` (必填): 優惠券序號

**請求範例**:
```javascript
fetch('/api/coupon/claim-by-code/WELCOME20', {
    method: 'GET',
    credentials: 'include'
})
```

**成功回應** (HTTP 200):
```json
{
  "s": 1,
  "msg": "優惠券領取成功",
  "data": {
    "redemption_id": 123,
    "coupon_id": 1,
    "coupon_code": "WELCOME20",
    "redemption_at": "2025-01-15 10:30:00"
  }
}
```

**錯誤回應** (HTTP 400):
```json
{
  "s": 0,
  "msg": "序號不能為空"
}
```

```json
{
  "s": 0,
  "msg": "此優惠券未啟用或已失效"
}
```

```json
{
  "s": 0,
  "msg": "此優惠券活動尚未開始"
}
```

```json
{
  "s": 0,
  "msg": "此優惠券活動已結束"
}
```

```json
{
  "s": 0,
  "msg": "此優惠券領取尚未開始"
}
```

```json
{
  "s": 0,
  "msg": "此優惠券領取已結束"
}
```

```json
{
  "s": 0,
  "msg": "優惠券領取失敗，可能已達領取次數限制、不符合資格或優惠券已失效"
}
```

**錯誤回應** (HTTP 401):
```json
{
  "s": 0,
  "msg": "請先登入會員"
}
```

**錯誤回應** (HTTP 403):
```json
{
  "s": 0,
  "msg": "您的會員等級不符合此優惠券的領取資格"
}
```

**錯誤回應** (HTTP 404):
```json
{
  "s": 0,
  "msg": "無效的優惠券序號"
}
```

```json
{
  "s": 0,
  "msg": "會員資料不存在"
}
```

**檢查項目**:
- 序號不能為空
- 優惠券狀態（必須啟用）
- 活動時間範圍
- 領取時間範圍
- 會員等級限制
- 領取次數限制
- 批次發碼模式下，檢查序號是否已被使用

**使用場景**:
- 行銷活動優惠券分享連結領取
- 批次發放的優惠券序號領取
- 單一序號優惠券領取

**注意事項**:
- 此 API 支援兩種模式：
  1. **單一序號模式**：優惠券的 `code` 欄位直接作為序號
  2. **批次發碼模式**：從 `coupon_codes` 表查詢，每個序號只能被使用一次
- 如果是批次發碼模式，領取成功後會自動更新 `coupon_codes` 表的狀態為 `used` 並關聯到會員 ID
- 行銷活動類型的優惠券必須填寫序號才能使用此 API

---

### 4. 取得登入自行領取的優惠券列表

**端點**: `GET /api/coupon/list`

**說明**: 取得可自行領取的優惠券列表（`distribution_method=2`）。

**認證**: 需要會員登入（`auth:member`）

**請求範例**:
```javascript
fetch('/api/coupon/list', {
    method: 'GET',
    credentials: 'include'
})
```

**成功回應** (HTTP 200):
```json
{
  "s": 1,
  "data": [
    {
      "id": 1,
      "title": "新會員歡迎禮",
      "code": "WELCOME20",
      "image_url": "https://example.com/coupon.jpg",
      "coupon_category": 4,
      "type": 1,
      "value": 0.2,
      "max_discount_amount": 2000,
      "condition_type": 2,
      "condition_metric": 1,
      "condition_threshold": 1000,
      "limit_scope": 2,
      "activity_starts_at": "2025-01-01 00:00:00",
      "activity_ends_at": "2025-12-31 23:59:59",
      "redemption_starts_at": "2025-01-01 00:00:00",
      "redemption_ends_at": "2025-12-31 23:59:59",
      "redemption_limit_type": 2,
      "redemption_limit_count": 3,
      "has_redeemed": false,
      "redemption_count": 0
    }
  ]
}
```

**回應欄位說明**:
- `id`: 優惠券 ID
- `title`: 優惠券名稱
- `code`: 優惠券序號
- `image_url`: 優惠券圖片網址
- `coupon_category`: 優惠券類型（1=會員升級禮, 2=會員生日禮, 3=滿額贈, 4=行銷活動）
- `type`: 優惠方式（1=折價券, 2=現金券, 4=禮物券）
- `value`: 面額/折數（折價券為 0-1 之間的小數，現金券為金額，禮物券為 null）
- `max_discount_amount`: 百分比封頂金額（僅折價券適用）
- `condition_type`: 生效條件（1=無條件, 2=當整筆訂單達到）
- `condition_metric`: 門檻種類（1=最低金額, 2=最少件數）
- `condition_threshold`: 門檻數值
- `limit_scope`: 使用範圍限制（1=不限制, 2=僅限指定商品, 4=僅限指定賣場）
- `has_redeemed`: 是否已領取
- `redemption_count`: 已領取次數

---

### 5. 取得登入自動送的優惠券列表

**端點**: `GET /api/coupon/auto-grant-list`

**說明**: 取得登入自動送的優惠券列表（`distribution_method=1`）。這些優惠券會在 App/網頁啟動時自動發放。

**認證**: 需要會員登入（`auth:member`）

**請求範例**:
```javascript
fetch('/api/coupon/auto-grant-list', {
    method: 'GET',
    credentials: 'include'
})
```

**成功回應** (HTTP 200):
```json
{
  "s": 1,
  "data": [
    {
      "id": 2,
      "title": "每日登入禮",
      "code": "DAILY_LOGIN",
      "image_url": "https://example.com/coupon2.jpg",
      "coupon_category": 4,
      "type": 2,
      "value": 100,
      "max_discount_amount": null,
      "condition_type": 1,
      "condition_metric": null,
      "condition_threshold": null,
      "limit_scope": 1,
      "activity_starts_at": "2025-01-01 00:00:00",
      "activity_ends_at": "2025-12-31 23:59:59",
      "redemption_starts_at": "2025-01-01 00:00:00",
      "redemption_ends_at": "2025-12-31 23:59:59",
      "redemption_limit_type": 1,
      "redemption_limit_count": null,
      "has_redeemed": true,
      "redemption_count": 1
    }
  ]
}
```

**回應格式**: 與「登入自行領取的優惠券列表」相同

---

### 6. 取得我的優惠券（已領取）

**端點**: `GET /api/coupon/my-coupons`

**說明**: 取得會員已領取的優惠券列表，支援分頁和狀態篩選。

**認證**: 需要會員登入（`auth:member`）

**查詢參數**:
- `page` (選填): 頁碼，預設 1
- `per_page` (選填): 每頁筆數，預設 20，最大 100
- `status` (選填): 狀態篩選，1=未使用, 2=已使用, 4=已過期

**請求範例**:
```javascript
// 取得未使用的優惠券，第 1 頁，每頁 20 筆
fetch('/api/coupon/my-coupons?status=1&page=1&per_page=20', {
    method: 'GET',
    credentials: 'include'
})
```

**成功回應** (HTTP 200):
```json
{
  "s": 1,
  "data": [
    {
      "redemption_id": 123,
      "coupon_id": 1,
      "coupon_code": "WELCOME20",
      "title": "新會員歡迎禮",
      "image_url": "https://example.com/coupon.jpg",
      "coupon_category": 4,
      "type": 1,
      "value": 0.2,
      "max_discount_amount": 2000,
      "condition_type": 2,
      "condition_metric": 1,
      "condition_threshold": 1000,
      "limit_scope": 2,
      "redemption_at": "2025-01-15 10:30:00",
      "status": "未使用",
      "status_value": 1,
      "used_at": null,
      "order_id": null,
      "discount_amount": null,
      "activity_starts_at": "2025-01-01 00:00:00",
      "activity_ends_at": "2025-12-31 23:59:59"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_records": 100,
    "per_page": 20
  }
}
```

**回應欄位說明**:
- `redemption_id`: 領取記錄 ID
- `coupon_id`: 優惠券 ID
- `coupon_code`: 優惠券序號
- `status`: 使用狀態文字（未使用/已使用/已過期）
- `status_value`: 使用狀態數值（1=未使用, 2=已使用, 4=已過期）
- `used_at`: 使用時間（未使用時為 null）
- `order_id`: 訂單編號（未使用時為 null）
- `discount_amount`: 折抵金額（未使用時為 null）

---

### 7. 使用優惠券

**端點**: `POST /api/coupon/use`

**說明**: 結帳時使用優惠券，系統會檢查使用條件並計算折抵金額。

**認證**: 需要會員登入（`auth:member`）

**請求參數**:
```json
{
  "redemption_id": 123,
  "order_id": "ORD20250101001",
  "order_amount": 1000,
  "order_items": [
    {
      "product_id": 1,
      "store_id": 2,
      "amount": 500
    },
    {
      "product_id": 3,
      "store_id": 2,
      "amount": 500
    }
  ]
}
```

**參數說明**:
- `redemption_id` (必填): 領取記錄 ID（從「我的優惠券」取得）
- `order_id` (必填): 訂單編號
- `order_amount` (必填): 訂單總金額
- `order_items` (選填): 訂單商品列表，用於檢查使用範圍限制
  - `product_id`: 商品 ID
  - `store_id`: 賣場 ID
  - `amount`: 商品金額

**請求範例**:
```javascript
fetch('/api/coupon/use', {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        redemption_id: 123,
        order_id: 'ORD20250101001',
        order_amount: 1000,
        order_items: [
            { product_id: 1, store_id: 2, amount: 500 },
            { product_id: 3, store_id: 2, amount: 500 }
        ]
    })
})
```

**成功回應** (HTTP 200):
```json
{
  "s": 1,
  "msg": "優惠券使用成功",
  "data": {
    "redemption_id": 123,
    "discount_amount": 200,
    "order_id": "ORD20250101001",
    "used_at": "2025-01-15 10:30:00"
  }
}
```

**錯誤回應** (HTTP 400):
```json
{
  "s": 0,
  "msg": "優惠券已使用，無法使用"
}
```

```json
{
  "s": 0,
  "msg": "優惠券已過期"
}
```

```json
{
  "s": 0,
  "msg": "優惠券使用失敗，可能不符合使用條件"
}
```

**錯誤回應** (HTTP 404):
```json
{
  "s": 0,
  "msg": "優惠券領取記錄不存在"
}
```

**錯誤回應** (HTTP 422):
```json
{
  "s": 0,
  "msg": "驗證失敗",
  "errors": {
    "redemption_id": ["redemption_id 欄位為必填"],
    "order_id": ["order_id 欄位為必填"],
    "order_amount": ["order_amount 欄位為必填"]
  }
}
```

**檢查項目**:
- 優惠券狀態（必須未使用）
- 優惠券是否過期
- 生效條件（最低訂單金額/件數）
- 使用範圍限制（指定商品/賣場）

**折抵金額計算**:
- **折價券** (`type=1`): `訂單金額 × value`，如有封頂則不超過 `max_discount_amount`
- **現金券** (`type=2`): 固定金額 `value`，但不超過訂單金額
- **禮物券** (`type=4`): 不折抵金額（`discount_amount=0`）

---

## 前端整合建議

### 1. App 啟動時檢查自動送優惠券

```javascript
// App 啟動時
async function checkAutoGrantCoupons() {
    try {
        const response = await fetch('/api/coupon/check-auto-grant', {
            method: 'GET',
            credentials: 'include',
            headers: { 'Content-Type': 'application/json' }
        });
        
        const result = await response.json();
        
        if (result.s === 1 && result.data.granted_count > 0) {
            // 顯示通知：已自動發放優惠券
            console.log(`已自動發放 ${result.data.granted_count} 張優惠券`);
            // 可以顯示通知給用戶
            showNotification(`已自動發放 ${result.data.granted_count} 張優惠券`);
        }
    } catch (error) {
        console.error('檢查自動送優惠券失敗', error);
    }
}

// App 啟動時
checkAutoGrantCoupons();

// 或網頁載入時
window.addEventListener('load', checkAutoGrantCoupons);
```

### 2. 避免重複呼叫

- 建議加入 debounce 機制，避免短時間內重複呼叫 `check-auto-grant`
- 或使用快取，記錄最後一次呼叫時間

```javascript
let lastCheckTime = 0;
const CHECK_INTERVAL = 60000; // 60 秒內不重複檢查

async function checkAutoGrantCoupons() {
    const now = Date.now();
    if (now - lastCheckTime < CHECK_INTERVAL) {
        return; // 短時間內不重複檢查
    }
    lastCheckTime = now;
    
    // ... 執行檢查邏輯
}
```

### 3. 錯誤處理

所有 API 都需要處理未登入情況（401）和其他錯誤：

```javascript
async function handleApiError(response) {
    if (response.status === 401) {
        // 未登入，導向登入頁面
        window.location.href = '/login';
        return;
    }
    
    const result = await response.json();
    if (result.s === 0) {
        // 顯示錯誤訊息
        alert(result.msg || '操作失敗');
    }
}
```

### 4. 統一 API 呼叫函數

建議建立統一的 API 呼叫函數：

```javascript
const API_BASE_URL = '/api/coupon';

async function callCouponAPI(endpoint, options = {}) {
    const defaultOptions = {
        credentials: 'include',
        headers: {
            'Content-Type': 'application/json',
        }
    };
    
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
        ...defaultOptions,
        ...options,
        headers: {
            ...defaultOptions.headers,
            ...options.headers,
        }
    });
    
    if (response.status === 401) {
        // 未登入處理
        window.location.href = '/login';
        return null;
    }
    
    return await response.json();
}

// 使用範例
const coupons = await callCouponAPI('/list', { method: 'GET' });
```

---

## 優惠券類型說明

### 優惠券分類 (coupon_category)
- `1`: 會員升級禮
- `2`: 會員生日禮
- `3`: 滿額贈
- `4`: 行銷活動

### 優惠方式 (type)
- `1`: 折價券（百分比折扣）
- `2`: 現金券（固定金額）
- `4`: 禮物券（贈品）

### 生效條件 (condition_type)
- `1`: 無條件
- `2`: 當整筆訂單達到（需要配合 `condition_metric` 和 `condition_threshold`）

### 門檻種類 (condition_metric)
- `1`: 最低金額
- `2`: 最少件數

### 使用範圍限制 (limit_scope)
- `1`: 不限制
- `2`: 僅限指定商品使用
- `4`: 僅限指定賣場使用

### 領取方式 (distribution_method)
- `1`: 登入自動送
- `2`: 登入自行領取
- `4`: 排程發送

### 使用狀態 (status)
- `1`: 未使用
- `2`: 已使用
- `4`: 已過期

---

## 常見問題

### Q: 為什麼 `check-auto-grant` 未登入時不返回錯誤？

A: 因為此 API 是在 App/網頁啟動時呼叫，用戶可能尚未登入。未登入時不視為錯誤，只是不發放優惠券。

### Q: 優惠券領取和使用有什麼區別？

A: 
- **領取**：會員取得優惠券的使用權（建立 `coupon_user_redemptions` 記錄，狀態為「未使用」）
- **使用**：在結帳時實際使用優惠券（更新記錄狀態為「已使用」，記錄訂單編號和折抵金額）

### Q: 如何判斷優惠券是否可用？

A: 檢查以下條件：
1. `status = 1`（未使用）
2. `activity_ends_at` 未過期
3. 符合使用條件（訂單金額/件數、商品/賣場限制）

### Q: 折價券的 value 如何理解？

A: 
- `value = 0.8` 表示 8 折（折扣 20%）
- `value = 0.1` 表示 1 折（折扣 90%）
- `value = 1.0` 表示免費（折扣 100%）

### Q: 為什麼有兩個列表 API？

A: 
- `/api/coupon/list`：顯示「登入自行領取」的優惠券（會員需要主動領取）
- `/api/coupon/auto-grant-list`：顯示「登入自動送」的優惠券（App 啟動時自動發放）

---

## 更新記錄

- 2025-01-15: 初始版本，包含所有會員端 API 說明
- 2025-01-XX: 新增「透過序號領取優惠券」API (`/api/coupon/claim-by-code/{code}`)，支援行銷活動優惠券分享連結領取功能
