更新會員個人資料

**功能**: 更新當前登入會員的個人資料（姓名、Email、生日、性別、通知設定、頭像、密碼）

**端點**: `POST /api/member/update-profile`

**認證**: 需要（`auth:member`）

### 輸入參數

| 參數 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `name` | string | 否 | 會員姓名（最多100字元） |
| `email` | string | 否 | Email 地址（最多255字元，可設為空字串或 null 來清除） |
| `birthday` | string | 否 | 生日（日期格式，例如：1990-01-01，可設為空字串或 null 來清除） |
| `gender` | integer | 否 | 性別（1=男, 2=女, 4=其他，可設為 null 來清除） |
| `avatar` | string | 否 | 頭像網址（最多500字元，可設為空字串或 null 來清除） |
| `accept_activity_push` | integer | 否 | 活動推播通知（0=關閉, 1=開啟） |
| `accept_service_push` | integer | 否 | 服務推播通知（0=關閉, 1=開啟） |
| `accept_coupon_push` | integer | 否 | 優惠券推播通知（0=關閉, 1=開啟） |
| `accept_activity_email` | integer | 否 | 活動 Email 通知（0=關閉, 1=開啟） |
| `accept_activity_sms` | integer | 否 | 活動簡訊通知（0=關閉, 1=開啟） |
| `old_password` | string | 條件必填 | 舊密碼（修改密碼時必填） |
| `password` | string | 否 | 新密碼（6-50字元，需提供 `password_confirmation`） |
| `password_confirmation` | string | 條件必填 | 確認新密碼（與 `password` 相同） |

### 輸出格式

**成功** (HTTP 200):
```json
{
  "s": 1,
  "msg": "會員資料已更新",
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
    "gender": 1,
    "accept_activity_push": 1,
    "accept_service_push": 1,
    "accept_coupon_push": 1,
    "accept_activity_email": 1,
    "accept_activity_sms": 0
  }
}
```

**失敗** (HTTP 400/401/422/500):
```json
{
  "s": 0,
  "msg": "錯誤訊息",
  "errors": {
    "email": ["Email 格式不正確"]
  }
}
```

### 特殊說明

- **所有欄位都是可選的**：只需要傳送要更新的欄位即可
- **密碼修改**：修改密碼時必須提供 `old_password`（舊密碼）和 `password`（新密碼）以及 `password_confirmation`（確認新密碼）
- **舊密碼驗證**：系統會驗證舊密碼是否正確，錯誤時會返回 400 錯誤
- **只能修改自己的資料**：從 Session 取得會員 ID，無法修改其他會員的資料
- **不允許修改的欄位**：會員等級（`member_level`）、狀態（`status`）、手機號碼（`mobile`）、國碼（`country_code`）等敏感欄位無法透過此 API 修改
- **空值處理**：Email、生日、性別、頭像可以設為空字串或 null 來清除該欄位
- **更新後回傳最新資料**：成功更新後會回傳更新後的完整會員資料

### 使用範例

**只更新姓名和 Email**:
```json
{
  "name": "李四",
  "email": "newemail@example.com"
}
```

**只更新密碼**:
```json
{
  "old_password": "oldpassword123",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

**更新通知設定**:
```json
{
  "accept_activity_push": 1,
  "accept_service_push": 0,
  "accept_coupon_push": 1,
  "accept_activity_email": 1,
  "accept_activity_sms": 0
}
```