# Next.js API 串接文件

## Base URL
```
/api
```

---

## 身份驗證 API (Authentication)

### 1. 登入
**POST** `/api/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": {
    "id": 1,
    "name": "用戶名稱",
    "email": "user@example.com"
  }
}
```

---

### 2. 註冊
**POST** `/api/auth/signup`

**Request Body:**
```json
{
  "name": "用戶名稱",
  "email": "user@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "Bearer",
  "user": {
    "id": 1,
    "name": "用戶名稱",
    "email": "user@example.com"
  }
}
```

---

### 3. 取得當前用戶資訊 🔒
**GET** `/api/auth/user`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "id": 1,
  "name": "用戶名稱",
  "email": "user@example.com",
  "phone": "0912345678",
  "bonus": 100
}
```

---

### 4. 登出 🔒
**POST** `/api/auth/logout`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "message": "Successfully logged out"
}
```

---

### 5. 取得用戶地址列表 🔒
**GET** `/api/auth/addresses`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "家裡",
    "recipient": "王小明",
    "phone": "0912345678",
    "city": "台北市",
    "district": "中正區",
    "address": "重慶南路一段122號",
    "is_default": true
  }
]
```

---

## 首頁 API (Landing Page)

### 6. 取得商品分類
**GET** `/api/landing/categories`

**Response:**
```json
[
  {
    "id": 1,
    "name": "豬肉",
    "slug": "pork",
    "image": "/images/categories/pork.jpg",
    "order": 1
  }
]
```

---

### 7. 取得輪播圖
**GET** `/api/landing/banners`

**Response:**
```json
[
  {
    "id": 1,
    "title": "春節特惠",
    "image": "/images/banners/banner1.jpg",
    "link": "/shop/special",
    "order": 1
  }
]
```

---

## 聯絡我們 API

### 8. 發送聯絡表單
**POST** `/api/contact`

**Request Body:**
```json
{
  "name": "王小明",
  "email": "contact@example.com",
  "phone": "0912345678",
  "message": "我想詢問商品資訊"
}
```

**Response:**
```json
{
  "message": "已收到您的訊息，我們會盡快回覆"
}
```

---

## 購物頁面 API (Shop)

### 9. 取得分類路徑
**GET** `/api/shop/paths`

**Response:**
```json
[
  {
    "id": 1,
    "name": "豬肉",
    "slug": "pork",
    "parent_id": null
  },
  {
    "id": 2,
    "name": "梅花肉",
    "slug": "pork-shoulder",
    "parent_id": 1
  }
]
```

---

### 10. 取得分類商品
**GET** `/api/shop/{slug}`

**Parameters:**
- `slug` (string): 分類的 slug，例如 "pork"

**Response:**
```json
{
  "category": {
    "id": 1,
    "name": "豬肉",
    "slug": "pork",
    "description": "新鮮豬肉"
  },
  "products": [
    {
      "id": 1,
      "name": "國產梅花豬肉片",
      "price": 280,
      "sale_price": 250,
      "image": "/images/products/product1.jpg",
      "stock": 50,
      "unit": "盒"
    }
  ]
}
```

---

## 購物車 API (Kart)

### 11. 取得購物車項目
**GET** `/api/kart/items`

**Response:**
```json
{
  "items": [
    {
      "id": 1,
      "product_id": 10,
      "product_name": "國產梅花豬肉片",
      "price": 250,
      "quantity": 2,
      "subtotal": 500,
      "image": "/images/products/product1.jpg"
    }
  ],
  "total": 500
}
```

---

### 12. 加入購物車
**POST** `/api/kart/add`

**Request Body:**
```json
{
  "product_id": 10,
  "quantity": 2
}
```

**Response:**
```json
{
  "message": "已加入購物車",
  "kart_item": {
    "id": 1,
    "product_id": 10,
    "quantity": 2,
    "price": 250
  }
}
```

---

### 13. 移除購物車項目
**POST** `/api/kart/remove/{id}`

**Parameters:**
- `id` (integer): 購物車項目 ID

**Response:**
```json
{
  "message": "已從購物車移除"
}
```

---

## 訂單 API (Bill) 🔒

> ⚠️ 以下所有訂單 API 都需要登入驗證

### 14. 結帳 🔒
**POST** `/api/bill/checkout`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Request Body:**
```json
{
  "recipient": "王小明",
  "phone": "0912345678",
  "city": "台北市",
  "district": "中正區",
  "address": "重慶南路一段122號",
  "payment_method": "credit_card",
  "use_bonus": 50,
  "note": "請在下午送達"
}
```

**Response:**
```json
{
  "bill_id": 100,
  "total": 500,
  "bonus_used": 50,
  "final_total": 450,
  "payment_url": "https://payment.ecpay.com.tw/..."
}
```

---

### 15. 取得訂單列表 🔒
**GET** `/api/bill/list`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response:**
```json
[
  {
    "id": 100,
    "bill_no": "KP20250106001",
    "status": "paid",
    "total": 450,
    "created_at": "2025-01-06 14:30:00",
    "items_count": 3
  }
]
```

---

### 16. 取得訂單明細 🔒
**GET** `/api/bill/detail/{bill_id}`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Parameters:**
- `bill_id` (integer): 訂單 ID

**Response:**
```json
{
  "id": 100,
  "bill_no": "KP20250106001",
  "status": "paid",
  "total": 450,
  "recipient": "王小明",
  "phone": "0912345678",
  "address": "台北市中正區重慶南路一段122號",
  "items": [
    {
      "product_name": "國產梅花豬肉片",
      "quantity": 2,
      "price": 250,
      "subtotal": 500
    }
  ],
  "created_at": "2025-01-06 14:30:00"
}
```

---

### 17. 取得付款 Token 🔒
**GET** `/api/bill/token/{bill_id}`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Parameters:**
- `bill_id` (integer): 訂單 ID

**Response:**
```json
{
  "token": "abc123xyz",
  "payment_url": "https://payment.ecpay.com.tw/..."
}
```

---

### 18. 執行付款 🔒
**POST** `/api/bill/pay/{bill_id}`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Parameters:**
- `bill_id` (integer): 訂單 ID

**Request Body:**
```json
{
  "payment_method": "credit_card"
}
```

**Response:**
```json
{
  "success": true,
  "payment_url": "https://payment.ecpay.com.tw/...",
  "bill_id": 100
}
```

---

## 錯誤回應格式

所有 API 錯誤都會回傳以下格式：

```json
{
  "error": true,
  "message": "錯誤訊息",
  "code": 400
}
```

### 常見錯誤碼

- `400` - Bad Request (請求參數錯誤)
- `401` - Unauthorized (未授權，需要登入)
- `403` - Forbidden (無權限)
- `404` - Not Found (資源不存在)
- `422` - Validation Error (驗證錯誤)
- `500` - Server Error (伺服器錯誤)

---

## 驗證錯誤格式

當驗證失敗時 (422)，會回傳詳細的欄位錯誤：

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["email 欄位必填"],
    "password": ["password 至少需要 6 個字元"]
  }
}
```

---

## 註解說明

- 🔒 表示需要 Authorization Header (Bearer Token)
- 所有日期時間格式為 `Y-m-d H:i:s` (例如: 2025-01-06 14:30:00)
- 所有金額單位為新台幣 (NT$)

---

## 前端使用範例 (Next.js)

### 登入範例

```javascript
// lib/api.js
const API_BASE = '/api';

export async function login(email, password) {
  const response = await fetch(`${API_BASE}/auth/login`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, password }),
  });

  if (!response.ok) {
    throw new Error('Login failed');
  }

  const data = await response.json();
  localStorage.setItem('access_token', data.access_token);
  return data;
}
```

### 取得用戶資訊範例

```javascript
export async function getUser() {
  const token = localStorage.getItem('access_token');

  const response = await fetch(`${API_BASE}/auth/user`, {
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    throw new Error('Failed to fetch user');
  }

  return response.json();
}
```

### 加入購物車範例

```javascript
export async function addToKart(productId, quantity) {
  const response = await fetch(`${API_BASE}/kart/add`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      product_id: productId,
      quantity: quantity,
    }),
  });

  if (!response.ok) {
    throw new Error('Failed to add to cart');
  }

  return response.json();
}
```

---

## 開發注意事項

1. **CORS 設定**: 確保後端已正確設定 CORS headers
2. **Token 管理**: Access token 應安全儲存 (建議使用 httpOnly cookies 或安全的 localStorage)
3. **錯誤處理**: 前端應妥善處理所有可能的錯誤狀態碼
4. **Loading 狀態**: API 呼叫時應顯示 loading 指示器
5. **Token 過期**: 當收到 401 錯誤時，應重新導向至登入頁面
