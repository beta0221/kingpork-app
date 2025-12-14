# 會員認證 API 說明文件

## 概述

本文件說明會員認證系統的所有 API 端點，包含註冊、登入、登出、忘記密碼等功能。

**Base URL**: `/api/member`

**認證方式**: Session-based Authentication（使用 Laravel Session）

**重要說明**:
- 台灣（國碼 886）：使用手機簡訊驗證碼
- 其他國家：使用 Email 驗證碼（但仍使用手機號碼作為登入帳號）
- 所有 API 請求需包含 `credentials: 'include'` 以支援 Session Cookie
- 所有 API 回應格式統一為 `{ s: 0|1, msg: string, data?: object, errors?: object }`

---

## 1. 發送驗證碼

**功能**: 根據國碼發送簡訊驗證碼（台灣）或 Email 驗證碼（其他國家）

**端點**: `POST /api/member/send-verification-code`

**認證**: 不需要

### 輸入參數

| 參數 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `country_code` | string | 是 | 手機國碼（1-4位數字），例如：886（台灣）、1（美國） |
| `mobile` | string | 是 | 手機號碼（10-15位數字） |
| `email` | string | 條件必填 | Email 地址（僅非台灣國家需要） |

### 輸出格式

**成功** (HTTP 200):
```json
{
  "s": 1,
  "msg": "驗證碼已發送",
  "data": {
    "code": "123456"  // 僅開發環境返回
  }
}
```

**失敗** (HTTP 400/422):
```json
{
  "s": 0,
  "msg": "錯誤訊息",
  "errors": {
    "country_code": ["國碼格式不正確（應為1-4位數字）"]
  }
}
```

### 特殊說明
- 台灣（886）：發送簡訊驗證碼到手機
- 其他國家：發送 Email 驗證碼到指定 Email
- 驗證碼有頻率限制（60秒內只能發送一次）

---

## 2. 會員註冊

**功能**: 註冊新會員帳號

**端點**: `POST /api/member/register`

**認證**: 不需要

### 輸入參數

| 參數 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `country_code` | string | 是 | 手機國碼（1-4位數字） |
| `mobile` | string | 是 | 手機號碼（10-15位數字） |
| `password` | string | 是 | 密碼（6-50個字元） |
| `verification_code` | string | 是 | 驗證碼（6位數字） |
| `name` | string | 否 | 會員姓名（最多100字元） |
| `email` | string | 條件必填 | Email 地址（僅非台灣國家需要） |

### 輸出格式

**成功** (HTTP 201):
```json
{
  "s": 1,
  "msg": "註冊成功",
  "data": {
    "member_id": 10000,
    "name": "張三",
    "country_code": "886",
    "mobile": "0912345678",
    "email": "user@example.com"  // 僅非台灣國家返回
  }
}
```

**失敗** (HTTP 409/422/500):
```json
{
  "s": 0,
  "msg": "此手機號碼已被註冊",
  "errors": {
    "password": ["密碼長度至少6個字元"]
  }
}
```

### 特殊說明
- 會員ID格式：自動遞增的整數（BIGINT），從 10000 開始
- 會員ID由資料庫自動生成，無需手動指定
- 預設會員等級：1（TK俱樂部）
- 預設狀態：1（正常）
- 手機號碼會加密儲存
- 台灣：使用簡訊驗證碼驗證
- 其他國家：使用 Email 驗證碼驗證

---

## 3. 會員登入

**功能**: 會員登入，建立 Session

**端點**: `POST /api/member/login`

**認證**: 不需要

### 輸入參數

| 參數 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `country_code` | string | 是 | 手機國碼（1-4位數字） |
| `mobile` | string | 是 | 手機號碼 |
| `password` | string | 是 | 密碼 |

### 輸出格式

**成功** (HTTP 200):
```json
{
  "s": 1,
  "msg": "登入成功",
  "data": {
    "member": {
      "member_id": 10000,
      "name": "張三",
      "country_code": "886",
      "mobile": "0912345678",
      "email": "user@example.com",
      "member_level": 1,
      "avatar": "https://example.com/avatar.jpg"
    }
  }
}
```

**失敗** (HTTP 401/403/404/422/500):
```json
{
  "s": 0,
  "msg": "帳號或密碼錯誤"
}
```

### 特殊說明
- 登入成功後會自動更新 `last_login_time` 和 `last_login_at`
- 黑名單會員（status=8）無法登入
- 登入成功後會建立 Session，後續請求需攜帶 Session Cookie

---

## 4. 會員登出

**功能**: 登出會員，清除 Session

**端點**: `POST /api/member/logout`

**認證**: 需要（`auth:member`）

### 輸入參數

無

### 輸出格式

**成功** (HTTP 200):
```json
{
  "s": 1,
  "msg": "登出成功"
}
```

**失敗** (HTTP 500):
```json
{
  "s": 0,
  "msg": "登出失敗：錯誤訊息"
}
```

### 特殊說明
- 登出後會使 Session 無效並重新生成 CSRF token

---

## 5. 取得當前會員資訊

**功能**: 取得當前登入會員的詳細資訊

**端點**: `GET /api/member/me`

**認證**: 需要（`auth:member`）

### 輸入參數

無

### 輸出格式

**成功** (HTTP 200):
```json
{
  "s": 1,
  "data": {
    "member_id": 10000,
    "name": "張三",
    "country_code": "886",
    "mobile": "0912345678",
    "email": "user@example.com",
    "member_level": 1,
    "status": 1,
    "avatar": "https://example.com/avatar.jpg",
    "birthday": "1990-01-01",
    "gender": 1
  }
}
```

**失敗** (HTTP 401/404/500):
```json
{
  "s": 0,
  "msg": "未登入"
}
```

### 特殊說明
- 會從資料庫取得最新會員資料（非 Session 快取）

---

## 6. 刪除帳號

**功能**: 刪除會員帳號（軟刪除，標記 status=16）

**端點**: `POST /api/member/delete-account`

**認證**: 需要（`auth:member`）

### 輸入參數

無

### 輸出格式

**成功** (HTTP 200):
```json
{
  "s": 1,
  "msg": "帳號已刪除，感謝您的使用"
}
```

**失敗** (HTTP 401/500):
```json
{
  "s": 0,
  "msg": "刪除帳號失敗，請稍後再試"
}
```

### 特殊說明
- 會刪除 `member_auth` 表中的驗證資料
- 會將 `members` 表中的 `status` 設為 16（會員發動刪除）
- 刪除成功後會自動登出

---

## 7. 忘記密碼 - 發送驗證碼

**功能**: 發送密碼重設驗證碼

**端點**: `POST /api/member/password/send-reset-code`

**認證**: 不需要

### 輸入參數

| 參數 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `country_code` | string | 是 | 手機國碼（1-4位數字） |
| `mobile` | string | 是 | 手機號碼（10-15位數字） |
| `email` | string | 條件必填 | Email 地址（僅非台灣國家需要） |

### 輸出格式

**成功** (HTTP 200):
```json
{
  "s": 1,
  "msg": "驗證碼已發送",
  "data": {
    "code": "123456"  // 僅開發環境返回
  }
}
```

**失敗** (HTTP 400/403/404/422):
```json
{
  "s": 0,
  "msg": "此手機號碼尚未註冊"
}
```

### 特殊說明
- 會檢查會員狀態（已刪除、黑名單無法重設）
- 非台灣國家需驗證 Email 是否與帳號設定相符

---

## 8. 忘記密碼 - 驗證驗證碼

**功能**: 驗證驗證碼並產生重設密碼 Token

**端點**: `POST /api/member/password/verify-reset-code`

**認證**: 不需要

### 輸入參數

| 參數 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `country_code` | string | 是 | 手機國碼（1-4位數字） |
| `mobile` | string | 是 | 手機號碼（10-15位數字） |
| `verification_code` | string | 是 | 驗證碼（6位數字） |
| `email` | string | 條件必填 | Email 地址（僅非台灣國家需要） |

### 輸出格式

**成功** (HTTP 200):
```json
{
  "s": 1,
  "msg": "驗證成功，請重設密碼",
  "data": {
    "reset_token": "550e8400-e29b-41d4-a716-446655440000",
    "expires_in": 900
  }
}
```

**失敗** (HTTP 400/403/404/422):
```json
{
  "s": 0,
  "msg": "驗證碼錯誤或已過期"
}
```

### 特殊說明
- Token 有效期：15分鐘（900秒）
- Token 為一次性使用
- 驗證失敗會記錄到 `password_reset_logs` 表

---

## 9. 忘記密碼 - 重設密碼

**功能**: 使用 Token 重設密碼

**端點**: `POST /api/member/password/reset`

**認證**: 不需要

### 輸入參數

| 參數 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `reset_token` | string | 是 | 重設密碼 Token（從步驟8取得） |
| `password` | string | 是 | 新密碼（6-50個字元） |
| `password_confirmation` | string | 是 | 確認密碼（需與 password 一致） |

### 輸出格式

**成功** (HTTP 200):
```json
{
  "s": 1,
  "msg": "密碼已更新，請使用新密碼登入"
}
```

**失敗** (HTTP 400/403/422/429/500):
```json
{
  "s": 0,
  "msg": "重設密碼 Token 無效或已過期"
}
```

### 特殊說明
- 每日重設密碼次數限制：3次（以手機號碼計算）
- 超過限制會返回 HTTP 429
- 重設成功會記錄到 `password_reset_logs` 表
- **重設成功後不會自動登入**，需手動登入

---

## 10. 解密手機號碼（除錯用）

**功能**: 解密加密後的手機號碼字串（僅開發環境）

**端點**: `GET|POST /api/member/debug/decrypt-mobile`

**認證**: 不需要

### 輸入參數

| 參數 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `encrypted_text` | string | 是 | 加密後的手機號碼字串 |

### 輸出格式

**成功** (HTTP 200):
```json
{
  "s": 1,
  "msg": "解密成功",
  "data": {
    "decrypted": "0912345678"
  }
}
```

**失敗** (HTTP 403/422/500):
```json
{
  "s": 0,
  "msg": "此功能僅限除錯環境使用"
}
```

### 特殊說明
- 僅在 `APP_DEBUG=true` 時可用
- 生產環境會返回 403 Forbidden

---

## 錯誤碼說明

| HTTP 狀態碼 | 說明 |
|------------|------|
| 200 | 成功 |
| 201 | 建立成功（註冊） |
| 400 | 請求錯誤（驗證碼錯誤、Email 不符等） |
| 401 | 未認證（未登入、帳號密碼錯誤） |
| 403 | 禁止存取（黑名單、已刪除、除錯功能限制） |
| 404 | 資源不存在（會員不存在） |
| 409 | 衝突（手機號碼已被註冊） |
| 422 | 驗證失敗（輸入參數格式錯誤） |
| 429 | 請求過多（超過每日重設密碼次數限制） |
| 500 | 伺服器錯誤 |

---

## 會員狀態說明

| 狀態值 | 說明 |
|--------|------|
| 1 | 正常 |
| 2 | 停權 |
| 4 | 付款受限 |
| 8 | 黑名單 |
| 16 | 會員發動刪除 |

---

## 會員等級說明

| 等級值 | 說明 |
|--------|------|
| 1 | TK俱樂部 |
| 2 | TK金卡 |
| 4 | TK白金卡 |
| 8 | TK黑鑽卡 |

---

## 性別說明

| 值 | 說明 |
|----|------|
| 1 | 男 |
| 2 | 女 |
| 4 | 其他 |
| null | 未設定 |

---

## 注意事項

1. **Session Cookie**: 所有 API 請求需包含 `credentials: 'include'`（前端 Fetch API）或確保 Cookie 自動攜帶（瀏覽器自動處理）

2. **CORS 設定**: 需在 `config/cors.php` 中設定 `supports_credentials: true` 和允許的來源

3. **台灣 vs 其他國家**:
   - 台灣（886）：使用手機簡訊驗證碼
   - 其他國家：使用 Email 驗證碼，但登入帳號仍為手機號碼

4. **密碼重設限制**:
   - 每日最多 3 次（以手機號碼計算）
   - 使用 Redis 記錄每日次數，每日 00:00 重置

5. **資料加密**:
   - 手機號碼：使用 Laravel `Crypt::encryptString()` 加密儲存
   - 密碼：使用 `Hash::make()` 雜湊儲存

6. **驗證碼頻率限制**:
   - 簡訊驗證碼：60秒內只能發送一次
   - Email 驗證碼：依 `EmailVerificationService` 設定

7. **資料庫**:
   - 主要資料表：`members`、`member_auth`
   - 密碼重設記錄：`password_reset_logs`
   - 資料庫名稱：`TK2025`
   - 會員ID：使用 `members.id`（BIGINT UNSIGNED），從 10000 開始自動遞增

---

## 範例請求（JavaScript）

```javascript
// 登入
fetch('/api/member/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
  },
  credentials: 'include',  // 重要：攜帶 Cookie
  body: JSON.stringify({
    country_code: '886',
    mobile: '0912345678',
    password: 'password123'
  })
})
.then(response => response.json())
.then(data => {
  if (data.s === 1) {
    console.log('登入成功', data.data);
  } else {
    console.error('登入失敗', data.msg);
  }
});

// 取得會員資訊（需先登入）
fetch('/api/member/me', {
  method: 'GET',
  credentials: 'include'  // 重要：攜帶 Cookie
})
.then(response => response.json())
.then(data => {
  if (data.s === 1) {
    console.log('會員資訊', data.data);
  }
});
```

---
