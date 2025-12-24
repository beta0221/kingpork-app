# 商品相關 API 規格文檔

## 目錄
- [1. 商品列表頁 API](#1-商品列表頁-api)
- [2. 商品詳情頁 API](#2-商品詳情頁-api)
- [3. 快速分類 API](#3-快速分類-api)
- [4. 推薦商品 API](#4-推薦商品-api)

---

## 1. 商品列表頁 API

### 1.1 取得分類商品列表

**API 端點**: `GET /api/products/category`

**描述**: 取得特定分類的商品列表，包含橫幅資訊和分頁資料

**請求參數**:
| 參數名稱 | 類型 | 必填 | 說明 | 範例 |
|---------|------|------|------|------|
| category_id | string | 是 | 分類 ID | "cat_001" |
| page | integer | 否 | 頁碼（預設: 1） | 1 |
| page_size | integer | 否 | 每頁筆數（預設: 20） | 20 |
| sort_by | string | 否 | 排序方式（price_asc, price_desc, newest, popular） | "popular" |

**請求範例**:
```http
GET /api/products/category?category_id=cat_001&page=1&page_size=20&sort_by=popular
```

**回應格式**:
```json
{
  "status": "success",
  "data": {
    "category": {
      "id": "cat_001",
      "name": "保養精華",
      "banner": {
        "image": "https://img.tklab.com.tw/banners/serum_banner.webp",
        "title": "神經醯胺系列",
        "subtitle": "NEW ARRIVAL",
        "discount_percent": 15
      }
    },
    "products": [
      {
        "id": "prod_1562",
        "title": "神經醯胺特潤保濕精華液",
        "image": "https://img.tklab.com.tw/uploads/product/202509/1562_fe6fc98f84144cb1854a3c76278febb8ea4a22e8_m.webp",
        "price": 1280.0,
        "price_after_discount": 1088.0,
        "discount_percent": 15,
        "brand": "TKLAB",
        "is_available": true,
        "top_ranking": 1
      },
      {
        "id": "prod_8214",
        "title": "玻尿酸保濕精華液",
        "image": "https://img.tklab.com.tw/uploads/product/202509/8214_172e393014105dfccdfa52a691412ee712ed3224_m.webp",
        "price": 980.0,
        "price_after_discount": 880.0,
        "discount_percent": 10,
        "brand": "TKLAB",
        "is_available": true,
        "top_ranking": 2
      }
    ],
    "pagination": {
      "current_page": 1,
      "page_size": 20,
      "total_items": 156,
      "total_pages": 8,
      "has_next": true,
      "has_previous": false
    }
  }
}
```

**錯誤回應**:
```json
{
  "status": "error",
  "message": "分類不存在",
  "error_code": "CATEGORY_NOT_FOUND"
}
```

---

## 2. 商品詳情頁 API

### 2.1 取得商品詳細資訊

**API 端點**: `GET /api/products/{product_id}`

**描述**: 取得單一商品的完整詳細資訊

**路徑參數**:
| 參數名稱 | 類型 | 必填 | 說明 | 範例 |
|---------|------|------|------|------|
| product_id | string | 是 | 商品 ID | "prod_1562" |

**請求範例**:
```http
GET /api/products/prod_1562
```

**回應格式**:
```json
{
  "status": "success",
  "data": {
    "id": "prod_1562",
    "brand": "TKLAB",
    "title": "神經醯胺特潤保濕精華液",
    "description": "含有神經醯胺與玻尿酸的特潤保濕精華液，能深層滋潤肌膚，強化肌膚屏障，改善乾燥缺水問題。溫和不刺激，適合各種膚質使用，讓肌膚水潤飽滿有光澤。",
    "images": [
      "https://img.tklab.com.tw/uploads/product/202509/1562_fe6fc98f84144cb1854a3c76278febb8ea4a22e8_m.webp",
      "https://img.tklab.com.tw/uploads/product/202509/1562_5e8c2aa9a2288a65dfdc43c5df7f6d38b4dc99e2_m.webp",
      "https://img.tklab.com.tw/uploads/product/202509/1562_36a61623c23493ba954b16e5d49348c54ff3e2d5_m.webp"
    ],
    "price": 1280.0,
    "price_after_discount": 1088.0,
    "discount_percent": 15,
    "is_available": true,
    "rating": 4.8,
    "num_of_reviews": 235,
    "specifications": {
      "capacity": "30ml",
      "ingredients": [
        "神經醯胺",
        "玻尿酸",
        "維他命B5",
        "角鯊烷"
      ],
      "usage": "早晚清潔後，取適量均勻塗抹於臉部，輕拍至吸收",
      "shelf_life": "未開封3年，開封後12個月內使用完畢",
      "origin": "台灣",
      "suitable_for": [
        "乾性肌膚",
        "敏感肌膚",
        "缺水肌膚"
      ]
    },
    "shipping_info": {
      "methods": [
        {
          "id": "ship_001",
          "name": "宅配到府",
          "fee": 80,
          "free_shipping_threshold": 1000,
          "estimated_days": "2-3個工作天"
        },
        {
          "id": "ship_002",
          "name": "超商取貨",
          "fee": 60,
          "free_shipping_threshold": 1000,
          "estimated_days": "3-5個工作天"
        }
      ],
      "payment_methods": [
        {
          "id": "pay_001",
          "name": "信用卡",
          "description": "支援 VISA、MasterCard、JCB"
        },
        {
          "id": "pay_002",
          "name": "ATM 轉帳",
          "description": "虛擬帳號繳費，3天內完成付款"
        },
        {
          "id": "pay_003",
          "name": "超商取貨付款",
          "description": "取貨時付現"
        }
      ]
    },
    "return_policy": {
      "returnable": true,
      "return_period_days": 7,
      "conditions": [
        "商品未使用、未拆封",
        "保持商品完整性（含包裝、配件）",
        "退貨需自付運費",
        "特價商品、贈品不適用退貨"
      ],
      "process": "請於訂單詳情頁面申請退貨，客服將於1-2個工作天內與您聯繫"
    }
  }
}
```

**錯誤回應**:
```json
{
  "status": "error",
  "message": "商品不存在",
  "error_code": "PRODUCT_NOT_FOUND"
}
```

### 2.2 取得商品推薦列表

**API 端點**: `GET /api/products/{product_id}/recommendations`

**描述**: 取得「其他人也看了」的推薦商品列表

**路徑參數**:
| 參數名稱 | 類型 | 必填 | 說明 | 範例 |
|---------|------|------|------|------|
| product_id | string | 是 | 商品 ID | "prod_1562" |

**請求參數**:
| 參數名稱 | 類型 | 必填 | 說明 | 範例 |
|---------|------|------|------|------|
| limit | integer | 否 | 回傳筆數（預設: 10） | 10 |

**請求範例**:
```http
GET /api/products/prod_1562/recommendations?limit=10
```

**回應格式**:
```json
{
  "status": "success",
  "data": {
    "products": [
      {
        "id": "prod_8214",
        "title": "玻尿酸保濕精華液",
        "image": "https://img.tklab.com.tw/uploads/product/202509/8214_172e393014105dfccdfa52a691412ee712ed3224_m.webp",
        "brand": "TKLAB",
        "price": 980.0,
        "price_after_discount": 880.0,
        "discount_percent": 10
      },
      {
        "id": "prod_7866",
        "title": "維他命C美白精華",
        "image": "https://img.tklab.com.tw/uploads/product/202509/7866_813c23705579855d172ded3d08beebf526185138_m.webp",
        "brand": "TKLAB",
        "price": 1180.0,
        "price_after_discount": null,
        "discount_percent": null
      },
      {
        "id": "prod_6800",
        "title": "膠原蛋白緊緻面霜",
        "image": "https://img.tklab.com.tw/uploads/product/202509/6800_1b2cebb4e091e00607b794207770c78836c5c022_m.webp",
        "brand": "TKLAB",
        "price": 1480.0,
        "price_after_discount": 1280.0,
        "discount_percent": 15
      }
    ]
  }
}
```

---

## 3. 快速分類 API

### 3.1 取得快速分類圖示列表

**API 端點**: `GET /api/categories/quick`

**描述**: 取得首頁和分類頁顯示的快速分類圖示列表

**請求範例**:
```http
GET /api/categories/quick
```

**回應格式**:
```json
{
  "status": "success",
  "data": {
    "categories": [
      {
        "id": "cat_001",
        "name": "精華液",
        "icon": "https://img.tklab.com.tw/icons/serum.svg",
        "product_count": 45
      },
      {
        "id": "cat_002",
        "name": "面霜",
        "icon": "https://img.tklab.com.tw/icons/cream.svg",
        "product_count": 32
      },
      {
        "id": "cat_003",
        "name": "面膜",
        "icon": "https://img.tklab.com.tw/icons/mask.svg",
        "product_count": 28
      },
      {
        "id": "cat_004",
        "name": "化妝水",
        "icon": "https://img.tklab.com.tw/icons/toner.svg",
        "product_count": 21
      },
      {
        "id": "cat_005",
        "name": "清潔",
        "icon": "https://img.tklab.com.tw/icons/cleanser.svg",
        "product_count": 19
      }
    ]
  }
}
```

---

## 4. 推薦商品 API

### 4.1 取得熱門商品排行

**API 端點**: `GET /api/products/ranking`

**描述**: 取得熱門商品排行榜（用於 TOP 1-9 標籤顯示）

**請求參數**:
| 參數名稱 | 類型 | 必填 | 說明 | 範例 |
|---------|------|------|------|------|
| category_id | string | 否 | 分類 ID（不提供則為全站排行） | "cat_001" |
| limit | integer | 否 | 回傳筆數（預設: 10） | 10 |

**請求範例**:
```http
GET /api/products/ranking?category_id=cat_001&limit=10
```

**回應格式**:
```json
{
  "status": "success",
  "data": {
    "products": [
      {
        "id": "prod_1562",
        "title": "神經醯胺特潤保濕精華液",
        "image": "https://img.tklab.com.tw/uploads/product/202509/1562_fe6fc98f84144cb1854a3c76278febb8ea4a22e8_m.webp",
        "price": 1280.0,
        "price_after_discount": 1088.0,
        "discount_percent": 15,
        "brand": "TKLAB",
        "ranking": 1,
        "sales_count": 1256
      },
      {
        "id": "prod_8214",
        "title": "玻尿酸保濕精華液",
        "image": "https://img.tklab.com.tw/uploads/product/202509/8214_172e393014105dfccdfa52a691412ee712ed3224_m.webp",
        "price": 980.0,
        "price_after_discount": 880.0,
        "discount_percent": 10,
        "brand": "TKLAB",
        "ranking": 2,
        "sales_count": 982
      }
    ]
  }
}
```

---

## 通用規範

### HTTP 狀態碼
- `200 OK`: 請求成功
- `400 Bad Request`: 請求參數錯誤
- `401 Unauthorized`: 未授權（需要登入）
- `404 Not Found`: 資源不存在
- `500 Internal Server Error`: 伺服器錯誤

### 錯誤代碼
| 錯誤代碼 | 說明 |
|---------|------|
| CATEGORY_NOT_FOUND | 分類不存在 |
| PRODUCT_NOT_FOUND | 商品不存在 |
| INVALID_PARAMETER | 參數格式錯誤 |
| INSUFFICIENT_STOCK | 庫存不足 |
| SERVER_ERROR | 伺服器錯誤 |

### 資料格式規範
- 所有日期時間使用 ISO 8601 格式：`2025-12-16T10:30:00+08:00`
- 價格使用浮點數，保留兩位小數
- 圖片 URL 使用完整的絕對路徑
- 文字編碼統一使用 UTF-8

### 認證方式
- 使用 Bearer Token 進行身份驗證
- Header 格式：`Authorization: Bearer {token}`
- 部分 API（如商品列表、商品詳情）可不需認證即可訪問

### 分頁規範
- `page`: 從 1 開始的頁碼
- `page_size`: 每頁筆數，預設 20，最大 100
- 回應包含 `pagination` 物件，提供完整的分頁資訊

---

## 畫面對應 API 使用說明

### 商品列表頁 (product_category_screen.dart)
需要使用的 API：
1. **GET /api/products/category** - 取得分類商品列表（含橫幅資訊）
2. **GET /api/categories/quick** - 取得快速分類圖示（QuickCategoryIcons 元件使用）

資料流程：
```
1. 進入分類頁面時，帶入 category_id
2. 呼叫 /api/products/category 取得該分類的商品列表和橫幅資訊
3. 呼叫 /api/categories/quick 取得快速分類圖示列表
4. 使用者滾動到底部時，增加 page 參數載入下一頁商品
```

### 商品詳情頁 (product_details_screen.dart)
需要使用的 API：
1. **GET /api/products/{product_id}** - 取得商品完整資訊（包含規格、運送、退貨資訊）
2. **GET /api/products/{product_id}/recommendations** - 取得「其他人也看了」推薦商品

資料流程：
```
1. 進入商品詳情頁時，帶入 product_id
2. 呼叫 /api/products/{product_id} 取得商品完整資訊
3. 顯示商品圖片輪播、基本資訊、價格、評分
4. 點擊「商品規格」時，顯示 specifications 內容
5. 點擊「送貨與付款方式」時，顯示 shipping_info 內容
6. 點擊「退貨須知」時，顯示 return_policy 內容
7. 呼叫 /api/products/{product_id}/recommendations 顯示推薦商品橫向滾動列表
```

---

## 備註
- 所有商品圖片 URL 應使用 CDN 加速，建議提供多種尺寸（縮圖、中圖、大圖）
- 排行榜數據建議使用快取機制，每小時更新一次即可
- 推薦商品可使用協同過濾演算法，根據使用者瀏覽記錄和購買記錄進行推薦
- 價格相關欄位（price, price_after_discount）如果有折扣時，兩個欄位都要提供；無折扣時 price_after_discount 為 null
