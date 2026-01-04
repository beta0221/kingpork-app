# TK 幣系統 API 文件

## 概述

本文檔說明 TK 幣系統的會員端 API 使用方式。所有 API 都需要會員登入認證（使用 Session 認證）。

## 認證方式

所有 TK 幣相關 API 都需要會員登入，使用 Laravel Session 認證：
- 需要在請求中包含 Session Cookie
- 使用 `credentials: 'include'` 確保 Cookie 被發送

---

## API 端點總覽

| 端點 | 方法 | 說明 | 認證 |
|------|------|------|------|
| `/api/tkcoin/balance` | GET | 取得當前餘額 | 需要 |
| `/api/tkcoin/use` | POST | 使用 TK 幣 | 需要 |
| `/api/tkcoin/expiring` | GET | 即將過期的 TK 幣列表 | 需要 |
| `/api/tkcoin/claim/{token}` | GET | 領取 TK 幣（行銷活動） | 需要 |
| `/api/tkcoin/getTKCoinsList` | GET | 取得交易記錄（統一 API） | 需要 |
| `/api/tkcoin/member/{memberId}/getTKCoinsList` | GET | 取得會員交易記錄（統一 API） | 需要 |
| `/api/tkcoin/member/{memberId}/grants` | GET | 取得記錄（舊 API，向後兼容） | 需要 |
| `/api/tkcoin/member/{memberId}/usages` | GET | 使用記錄（舊 API，向後兼容） | 需要 |

---

## API 詳細說明

### 1. 取得當前餘額

**端點**: `GET /api/tkcoin/balance`

**說明**: 取得當前登入會員的 TK 幣餘額。系統會從交易記錄計算實際有效餘額（排除已過期的 TK 幣）。

**認證**: 需要會員登入（`auth:member`）

**請求範例**:
```javascript
fetch('/api/tkcoin/balance', {
    method: 'GET',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' }
})
```

**成功回應** (HTTP 200):
```json
{
  "s": 1,
  "data": {
    "member_id": 10000,
    "member_name": "張三",
    "balance": 500,
    "balance_from_db": 500
  }
}
```

**回應欄位說明**:
- `member_id`: 會員 ID
- `member_name`: 會員名稱
- `balance`: 實際有效餘額（從交易記錄計算，排除已過期）
- `balance_from_db`: 資料庫中的餘額（用於對比）

**錯誤回應** (HTTP 401):
```json
{
  "s": 0,
  "msg": "請先登入會員"
}
```

**錯誤回應** (HTTP 404):
```json
{
  "s": 0,
  "msg": "會員不存在"
}
```

---

### 2. 使用 TK 幣

**端點**: `POST /api/tkcoin/use`

**說明**: 結帳時使用 TK 幣。系統會檢查餘額是否足夠，並支援訂單金額的 20% 限制檢查。

**認證**: 需要會員登入（`auth:member`）

**請求參數**:
```json
{
  "amount": 100,
  "description": "訂單 #12345 使用 TK 幣",
  "reference_id": "12345",
  "reference_type": "order",
  "order_amount": 1000
}
```

**參數說明**:
- `amount` (必填): 使用金額（必須為正整數）
- `description` (必填): 使用說明（最多 255 字元）
- `reference_id` (選填): 關聯 ID（例如：訂單編號）
- `reference_type` (選填): 關聯類型（例如：`order`、`system`）
- `order_amount` (選填): 訂單金額（用於檢查 20% 限制）

**請求範例**:
```javascript
fetch('/api/tkcoin/use', {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        amount: 100,
        description: '訂單 #12345 使用 TK 幣',
        reference_id: '12345',
        reference_type: 'order',
        order_amount: 1000
    })
})
```

**成功回應** (HTTP 200):
```json
{
  "s": 1,
  "msg": "TK幣使用成功",
  "data": {
    "amount": 100,
    "balance": 400,
    "transaction_id": 12345
  }
}
```

**錯誤回應** (HTTP 400):
```json
{
  "s": 0,
  "msg": "TK幣餘額不足"
}
```

```json
{
  "s": 0,
  "msg": "使用金額超過訂單金額的 20%"
}
```

**錯誤回應** (HTTP 401):
```json
{
  "s": 0,
  "msg": "請先登入會員"
}
```

**錯誤回應** (HTTP 422):
```json
{
  "s": 0,
  "msg": "驗證失敗",
  "errors": {
    "amount": ["amount 欄位為必填"],
    "description": ["description 欄位為必填"]
  }
}
```

**使用限制**:
- 使用金額不能超過當前餘額
- 如果提供 `order_amount`，使用金額不能超過訂單金額的 20%
- 使用金額必須為正整數

---

### 3. 即將過期的 TK 幣列表

**端點**: `GET /api/tkcoin/expiring`

**說明**: 取得即將在指定天數內過期的 TK 幣列表，幫助會員及時使用。

**認證**: 需要會員登入（`auth:member`）

**查詢參數**:
- `days` (選填): 查詢天數，預設 30 天
- `limit` (選填): 最多返回筆數，預設 50 筆

**請求範例**:
```javascript
// 查詢 30 天內即將過期的 TK 幣，最多返回 50 筆
fetch('/api/tkcoin/expiring?days=30&limit=50', {
    method: 'GET',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' }
})
```

**成功回應** (HTTP 200):
```json
{
  "s": 1,
  "data": {
    "member_id": 10000,
    "days_before_expire": 30,
    "expiring_list": [
      {
        "id": 123,
        "amount": 100,
        "description": "行銷活動：新春活動",
        "expires_at": "2025-02-15 23:59:59",
        "days_until_expire": 15,
        "source": "campaign",
        "source_text": "行銷活動",
        "created_at": "2025-01-15 10:00:00"
      },
      {
        "id": 124,
        "amount": 50,
        "description": "會員升級禮",
        "expires_at": "2025-02-20 23:59:59",
        "days_until_expire": 20,
        "source": "upgrade",
        "source_text": "升級禮",
        "created_at": "2025-01-20 10:00:00"
      }
    ],
    "total_count": 2,
    "total_amount": 150,
    "expired_count": 0,
    "expired_amount": 0
  }
}
```

**回應欄位說明**:
- `member_id`: 會員 ID
- `days_before_expire`: 查詢天數
- `expiring_list`: 即將過期的 TK 幣列表
  - `id`: 交易記錄 ID
  - `amount`: TK 幣金額
  - `description`: 說明
  - `expires_at`: 過期時間
  - `days_until_expire`: 距離過期的天數
  - `source`: 來源代碼
  - `source_text`: 來源文字
  - `created_at`: 建立時間
- `total_count`: 即將過期的總筆數
- `total_amount`: 即將過期的總金額
- `expired_count`: 已過期但未處理的筆數
- `expired_amount`: 已過期但未處理的金額

**錯誤回應** (HTTP 401):
```json
{
  "s": 0,
  "msg": "請先登入會員"
}
```

---

### 4. 領取 TK 幣（行銷活動）

**端點**: `GET /api/tkcoin/claim/{token}`

**說明**: 透過領取 Token 領取行銷活動的 TK 幣。此 API 主要用於「行銷活動」類型的 TK 幣活動（`grant_mode=4`）。

**認證**: 需要會員登入（`auth:member`）

**路徑參數**:
- `token` (必填): 領取 Token（從後台取得）

**請求範例**:
```javascript
fetch('/api/tkcoin/claim/abc123def456...', {
    method: 'GET',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' }
})
```

**成功回應** (HTTP 200):
```json
{
  "s": 1,
  "msg": "TK幣領取成功",
  "data": {
    "points": 100,
    "balance": 500,
    "transaction_id": 12345
  }
}
```

**錯誤回應** (HTTP 400):
```json
{
  "s": 0,
  "msg": "此活動已結束或未啟用"
}
```

```json
{
  "s": 0,
  "msg": "TK幣領取失敗，可能已達領取次數限制或不符合資格"
}
```

**錯誤回應** (HTTP 401):
```json
{
  "s": 0,
  "msg": "請先登入會員"
}
```

**錯誤回應** (HTTP 404):
```json
{
  "s": 0,
  "msg": "無效的領取連結"
}
```

**檢查項目**:
- 活動狀態（必須啟用）
- 活動時間範圍（`starts_at`、`ends_at`）
- 會員等級限制（`role_limit`）
- 領取次數限制（`receive_limit`）

**使用場景**:
- 行銷活動分享連結領取
- 活動推廣頁面領取

---

### 5. 取得交易記錄（統一 API）

**端點**: `GET /api/tkcoin/getTKCoinsList`

**說明**: 取得當前登入會員的 TK 幣交易記錄，支援多種過濾條件和分頁。

**認證**: 需要會員登入（`auth:member`）

**查詢參數**:
- `filter` (選填): 過濾類型，`grants`=已獲得、`usages`=已使用、`expired`=已過期、`all`=全部（預設）
- `limit` (選填): 每頁筆數，預設 100，最大建議 500
- `page` (選填): 頁碼，預設 1

**請求範例**:
```javascript
// 查詢已獲得的記錄，第 1 頁，每頁 50 筆
fetch('/api/tkcoin/getTKCoinsList?filter=grants&limit=50&page=1', {
    method: 'GET',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' }
})
```

**成功回應** (HTTP 200):
```json
{
  "s": 1,
  "data": {
    "member_id": 10000,
    "member_name": "張三",
    "current_balance": 500,
    "transactions": [
      {
        "id": 123,
        "type": 1,
        "type_text": "獲得",
        "amount": 100,
        "balance_after": 100,
        "source": "campaign",
        "source_text": "行銷活動",
        "description": "行銷活動：新春活動",
        "effective_at": "2025-01-15 10:00:00",
        "expires_at": "2025-12-31 23:59:59",
        "is_expired": 0,
        "created_at": "2025-01-15 10:00:00"
      },
      {
        "id": 124,
        "type": 2,
        "type_text": "使用",
        "amount": -50,
        "balance_after": 50,
        "source": "usage",
        "source_text": "使用",
        "description": "訂單 #12345 使用 TK 幣",
        "effective_at": null,
        "expires_at": null,
        "is_expired": 0,
        "created_at": "2025-01-16 14:30:00"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_records": 100,
      "per_page": 50
    }
  }
}
```

**回應欄位說明**:
- `member_id`: 會員 ID
- `member_name`: 會員名稱
- `current_balance`: 當前餘額
- `transactions`: 交易記錄列表
  - `id`: 交易記錄 ID
  - `type`: 交易類型（1=獲得, 2=使用, 4=過期, 8=手動調整）
  - `type_text`: 交易類型文字
  - `amount`: 金額（正數=獲得，負數=使用）
  - `balance_after`: 交易後餘額
  - `source`: 來源代碼
  - `source_text`: 來源文字
  - `description`: 說明
  - `effective_at`: 生效時間
  - `expires_at`: 過期時間
  - `is_expired`: 是否已過期（0=否, 1=是）
  - `created_at`: 建立時間
- `pagination`: 分頁資訊
  - `current_page`: 當前頁碼
  - `total_pages`: 總頁數
  - `total_records`: 總記錄數
  - `per_page`: 每頁筆數

**過濾類型說明**:
- `grants`: 已獲得（`type=1` 或 `type=8` 且 `amount>0`）
- `usages`: 已使用（`type=2` 或 `type=8` 且 `amount<0`）
- `expired`: 已過期（`type=4` 或 `is_expired=1` 或已過期的獲得記錄）
- `all`: 全部記錄（預設）

**注意事項**:
- 統一 API 支援分頁，建議使用 `limit` 和 `page` 參數控制返回筆數
- 舊 API (`grants`、`usages`) 不支援分頁，固定返回最多 100 筆
- 建議使用統一 API (`getTKCoinsList`) 取代舊 API

**錯誤回應** (HTTP 401):
```json
{
  "s": 0,
  "msg": "請先登入會員"
}
```

---

### 6. 取得會員交易記錄（統一 API，可指定 memberId）

**端點**: `GET /api/tkcoin/member/{memberId}/getTKCoinsList`

**說明**: 取得指定會員的 TK 幣交易記錄，功能與 `/api/tkcoin/getTKCoinsList` 相同，但可明確指定會員 ID。

**認證**: 需要會員登入（`auth:member`）

**路徑參數**:
- `memberId` (必填): 會員 ID

**查詢參數**:
- `filter` (選填): 過濾類型，`grants`=已獲得、`usages`=已使用、`expired`=已過期、`all`=全部（預設）
- `limit` (選填): 每頁筆數，預設 100
- `page` (選填): 頁碼，預設 1

**請求範例**:
```javascript
fetch('/api/tkcoin/member/10000/getTKCoinsList?filter=all&limit=50&page=1', {
    method: 'GET',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' }
})
```

**成功回應**: 與 `/api/tkcoin/getTKCoinsList` 相同

**錯誤回應** (HTTP 403):
```json
{
  "s": 0,
  "msg": "無權限查詢此會員的記錄"
}
```

**注意事項**:
- 會員只能查詢自己的記錄
- 如果 `memberId` 與當前登入會員 ID 不符，會返回 403 錯誤

---

### 7. 取得會員的 TK 幣取得記錄（舊 API，向後兼容）

**端點**: `GET /api/tkcoin/member/{memberId}/grants`

**說明**: 取得指定會員的 TK 幣取得記錄。此為舊 API，建議使用統一 API `/api/tkcoin/member/{memberId}/getTKCoinsList?filter=grants`。

**認證**: 需要會員登入（`auth:member`）

**路徑參數**:
- `memberId` (必填): 會員 ID

**請求範例**:
```javascript
fetch('/api/tkcoin/member/10000/grants', {
    method: 'GET',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' }
})
```

**成功回應** (HTTP 200):
```json
{
  "s": 1,
  "data": {
    "member_id": 10000,
    "member_name": "張三",
    "current_balance": 500,
    "grants": [
      {
        "id": 123,
        "type": 1,
        "type_text": "獲得",
        "amount": 100,
        "balance_after": 100,
        "source": "campaign",
        "source_text": "行銷活動",
        "description": "行銷活動：新春活動",
        "effective_at": "2025-01-15 10:00:00",
        "expires_at": "2025-12-31 23:59:59",
        "created_at": "2025-01-15 10:00:00"
      }
    ],
    "total_count": 1,
    "total_amount": 100
  }
}
```

**回應欄位說明**:
- `member_id`: 會員 ID
- `member_name`: 會員名稱
- `current_balance`: 當前餘額
- `grants`: 取得記錄列表
- `total_count`: 總筆數
- `total_amount`: 總金額

**錯誤回應** (HTTP 403):
```json
{
  "s": 0,
  "msg": "無權限查詢此會員的記錄"
}
```

---

### 8. 取得會員的 TK 幣使用記錄（舊 API，向後兼容）

**端點**: `GET /api/tkcoin/member/{memberId}/usages`

**說明**: 取得指定會員的 TK 幣使用記錄。此為舊 API，建議使用統一 API `/api/tkcoin/member/{memberId}/getTKCoinsList?filter=usages`。

**認證**: 需要會員登入（`auth:member`）

**路徑參數**:
- `memberId` (必填): 會員 ID

**請求範例**:
```javascript
fetch('/api/tkcoin/member/10000/usages', {
    method: 'GET',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' }
})
```

**成功回應** (HTTP 200):
```json
{
  "s": 1,
  "data": {
    "member_id": 10000,
    "member_name": "張三",
    "current_balance": 500,
    "usages": [
      {
        "id": 124,
        "type": 2,
        "type_text": "使用",
        "amount": -50,
        "balance_after": 50,
        "source": "usage",
        "source_text": "使用",
        "description": "訂單 #12345 使用 TK 幣",
        "created_at": "2025-01-16 14:30:00"
      }
    ],
    "total_count": 1,
    "total_amount": 50
  }
}
```

**回應欄位說明**:
- `member_id`: 會員 ID
- `member_name`: 會員名稱
- `current_balance`: 當前餘額
- `usages`: 使用記錄列表
- `total_count`: 總筆數
- `total_amount`: 總金額（使用金額的絕對值）

**錯誤回應** (HTTP 403):
```json
{
  "s": 0,
  "msg": "無權限查詢此會員的記錄"
}
```

---

## 前端整合建議

### 1. 統一 API 呼叫函數

建議建立統一的 API 呼叫函數：

```javascript
const API_BASE_URL = '/api/tkcoin';

async function callTKCoinAPI(endpoint, options = {}) {
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
const balance = await callTKCoinAPI('/balance', { method: 'GET' });
```

### 2. 錯誤處理

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

### 3. 定期檢查即將過期的 TK 幣

建議在會員登入後定期提醒即將過期的 TK 幣：

```javascript
async function checkExpiringTKCoins() {
    try {
        const response = await fetch('/api/tkcoin/expiring?days=7&limit=10', {
            method: 'GET',
            credentials: 'include',
            headers: { 'Content-Type': 'application/json' }
        });
        
        const result = await response.json();
        
        if (result.s === 1 && result.data.total_count > 0) {
            // 顯示提醒通知
            const totalAmount = result.data.total_amount;
            const days = result.data.days_before_expire;
            showNotification(`您有 ${totalAmount} 點 TK 幣將在 ${days} 天內過期，請盡快使用！`);
        }
    } catch (error) {
        console.error('檢查即將過期的 TK 幣失敗', error);
    }
}

// 會員登入後執行
checkExpiringTKCoins();
```

### 4. 使用 TK 幣時的 20% 限制檢查

在使用 TK 幣時，建議前端也進行 20% 限制檢查：

```javascript
async function useTKCoin(amount, orderAmount, description) {
    // 前端檢查：使用金額不能超過訂單金額的 20%
    if (orderAmount && amount > orderAmount * 0.2) {
        alert('使用金額不能超過訂單金額的 20%');
        return;
    }
    
    try {
        const response = await fetch('/api/tkcoin/use', {
            method: 'POST',
            credentials: 'include',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                amount: amount,
                description: description,
                order_amount: orderAmount,
                reference_type: 'order'
            })
        });
        
        const result = await response.json();
        
        if (result.s === 1) {
            // 使用成功，更新餘額顯示
            updateBalance(result.data.balance);
            return result.data;
        } else {
            alert(result.msg || '使用失敗');
            return null;
        }
    } catch (error) {
        console.error('使用 TK 幣失敗', error);
        alert('使用失敗，請稍後再試');
        return null;
    }
}
```

---

## TK 幣類型說明

### 交易類型 (type)
- `1`: 獲得
- `2`: 使用
- `4`: 過期
- `8`: 手動調整

### 來源類型 (source)
- `upgrade`: 升級禮
- `birthday`: 生日禮
- `threshold`: 滿額贈
- `campaign`: 行銷活動
- `manual`: 手動調整
- `usage`: 使用
- `expire`: 過期

### 關聯類型 (reference_type)
- `system`: 系統後台
- `claim_token`: 行銷活動領取
- `tkcoin_transaction`: TK幣交易
- `order`: 訂單

---

## 常見問題

### Q: 為什麼餘額顯示有 `balance` 和 `balance_from_db` 兩個值？

A: 
- `balance`: 從交易記錄計算的實際有效餘額（排除已過期的 TK 幣）
- `balance_from_db`: 資料庫中儲存的餘額（用於對比和除錯）

建議使用 `balance` 作為顯示餘額，因為它更準確地反映了當前可用的 TK 幣。

### Q: 使用 TK 幣有什麼限制？

A: 
1. 使用金額不能超過當前餘額
2. 如果提供 `order_amount`，使用金額不能超過訂單金額的 20%
3. 使用金額必須為正整數

### Q: 如何判斷 TK 幣是否已過期？

A: 檢查以下條件：
1. `type = 4`（過期類型）
2. `is_expired = 1`
3. `type = 1`（獲得類型）且 `expires_at` 已過期

### Q: 統一 API 和舊 API 有什麼區別？

A: 
- **統一 API** (`/api/tkcoin/getTKCoinsList`): 支援 `filter` 參數，可以過濾不同類型的記錄，並支援分頁
- **舊 API** (`/api/tkcoin/member/{memberId}/grants`、`/api/tkcoin/member/{memberId}/usages`): 只返回特定類型的記錄，不支援分頁

建議使用統一 API，功能更完整且更靈活。

### Q: 如何取得即將過期的 TK 幣？

A: 使用 `/api/tkcoin/expiring` API，可以設定查詢天數（例如：7 天、30 天）來取得即將過期的 TK 幣列表。

### Q: 領取 TK 幣失敗的原因有哪些？

A: 
1. 活動未啟用（`status !== 1`）
2. 活動尚未開始（`starts_at` 未到）
3. 活動已結束（`ends_at` 已過）
4. 會員等級不符合限制（`role_limit`）
5. 已達領取次數限制（`receive_limit`）

---

## 相關文件

- [TKCoin_Claim_API.md](./TKCoin_Claim_API.md) - 領取 Token API 詳細說明（行銷活動）
- [TKCoin_Member_History_API.md](./TKCoin_Member_History_API.md) - 會員記錄查詢 API 詳細說明（舊 API）
- [TKCoin_未實作功能清單.md](./TKCoin_未實作功能清單.md) - 未實作功能清單

---

## 更新記錄

- 2025-01-XX: 初始版本，包含所有會員端 TK 幣 API 說明
