# Phase 4.1 - 認證流程 進度報告

## 完成日期
2025-01-06

## 目前進度

### ✅ 已完成

**1. Service 層準備**
- ✅ `lib/services/auth_service.dart` - 已提供完整的認證 API
  - `login()` - 登入功能
  - `register()` - 註冊功能
  - `getUser()` - 取得用戶資料
  - `logout()` - 登出功能
  - `updateProfile()` - 更新個人資料

**2. ViewModel 層準備**
- ✅ `lib/viewmodels/member_view_model.dart` - 已實作完整的認證邏輯
  - 繼承 `BaseViewModel`（支援 loading/success/error 狀態）
  - `login()` - 登入方法
  - `signup()` - 註冊方法
  - `logout()` - 登出方法
  - `loadUserProfile()` - 載入用戶資料
  - `updateProfile()` - 更新資料
  - `checkTokenValidity()` - 檢查 Token 有效性

**3. 登入畫面更新**
- ✅ 更新 `lib/screens/auth/views/login_screen.dart`
  - 整合 `MemberViewModel`
  - 使用 `Consumer<MemberViewModel>` 監聽狀態
  - 完整的錯誤處理（ValidationException, UnauthorizedException, NetworkException, ApiException）
  - Loading 狀態顯示（CircularProgressIndicator）
  - 登入成功後導航到首頁

**4. LoginForm 元件更新**
- ✅ 更新 `lib/screens/auth/views/components/login_form.dart`
  - 改為 StatefulWidget 支援密碼顯示/隱藏切換
  - 新增 `onEmailChanged` 和 `onPasswordChanged` 回調
  - 新增密碼可見性切換按鈕（visibility icon）
  - 保留原有的 UI 設計和驗證邏輯

**5. 註冊畫面更新**
- ✅ 更新 `lib/screens/auth/views/signup_screen.dart`
  - 整合 `MemberViewModel.signup()`
  - 使用 `Consumer<MemberViewModel>` 監聽狀態
  - 完整的錯誤處理（ValidationException, UnauthorizedException, NetworkException, ApiException）
  - Loading 狀態顯示（CircularProgressIndicator）
  - 新增服務條款同意檢查
  - 註冊成功後導航到首頁

**6. SignUpForm 元件更新**
- ✅ 更新 `lib/screens/auth/views/components/sign_up_form.dart`
  - 改為 StatefulWidget
  - 新增 4 個回調參數（onNameChanged, onEmailChanged, onPasswordChanged, onPasswordConfirmationChanged）
  - 新增姓名欄位
  - 新增密碼確認欄位
  - 兩個密碼欄位都支援可見性切換
  - 密碼匹配驗證

**7. 程式碼驗證**
- ✅ Flutter analyze 通過（無錯誤）

---

## 實作細節

### 登入流程

```dart
// 1. 用戶輸入 email 和 password
// 2. LoginForm 透過 onEmailChanged/onPasswordChanged 回調傳遞
// 3. 點擊登入按鈕
// 4. _handleLogin() 驗證表單
// 5. viewModel.login(email, password)
// 6. AuthService.login() 呼叫 API
// 7. TokenManager 儲存 access token
// 8. 成功：導航到 entryPointScreenRoute
// 9. 失敗：顯示錯誤 SnackBar
```

### 註冊流程

```dart
// 1. 用戶輸入 name, email, password, password confirmation
// 2. SignUpForm 透過 4 個回調傳遞資料
// 3. 用戶勾選服務條款同意
// 4. 點擊 Continue 按鈕
// 5. _handleSignup() 驗證表單和服務條款同意
// 6. 密碼匹配驗證（在 SignUpForm 的 validator 中）
// 7. viewModel.signup(name, email, password, passwordConfirmation)
// 8. AuthService.register() 呼叫 API
// 9. TokenManager 儲存 access token
// 10. 成功：導航到 entryPointScreenRoute
// 11. 失敗：顯示錯誤 SnackBar
```

### 錯誤處理

**登入錯誤處理：**

| 異常類型 | 錯誤訊息 |
|---------|---------|
| ValidationException | 顯示所有驗證錯誤（join with '\n'） |
| UnauthorizedException | "帳號或密碼錯誤" |
| NetworkException | "無網路連線，請檢查網路設定" |
| ApiException | 顯示 API 返回的錯誤訊息 |
| 其他 | "登入時發生錯誤：{error}" |

**註冊錯誤處理：**

| 異常類型 | 錯誤訊息 |
|---------|---------|
| ValidationException | 顯示所有驗證錯誤（join with '\n'） |
| UnauthorizedException | "此帳號已被使用" |
| NetworkException | "無網路連線，請檢查網路設定" |
| ApiException | 顯示 API 返回的錯誤訊息 |
| 服務條款未同意 | "請同意服務條款與隱私政策" |
| 其他 | "註冊時發生錯誤：{error}" |

### UI 狀態管理

使用 `Consumer<MemberViewModel>` 監聽狀態變化：

```dart
Consumer<MemberViewModel>(
  builder: (context, viewModel, child) {
    return ElevatedButton(
      onPressed: viewModel.isLoading ? null : () => _handleLogin(viewModel),
      child: viewModel.isLoading
          ? CircularProgressIndicator() // 載入中
          : Text("Log in"),              // 正常狀態
    );
  },
)
```

---

## 待完成項目

### 📝 未完成（Phase 4.1 剩餘工作）

**1. 生物辨識（可選）**
- [ ] 創建 `lib/utils/biometric_auth.dart`
  - 從 tklabApp 遷移 `local_auth` 邏輯
  - 整合到登入流程

**2. 測試**
- [ ] 測試登入功能
- [ ] 測試註冊功能
- [ ] 測試錯誤處理
- [ ] 測試 Loading 狀態
- [ ] 測試 Token 儲存

**3. 完成文檔**
- [ ] 創建 `PHASE_4.1_COMPLETION.md`

---

## 檔案修改清單

### 已修改的檔案 (4 個)

1. **lib/screens/auth/views/login_screen.dart** (160 行)
   - 整合 MemberViewModel
   - 完整錯誤處理
   - Loading 狀態管理

2. **lib/screens/auth/views/components/login_form.dart** (109 行)
   - 改為 StatefulWidget
   - 新增密碼可見性切換
   - 新增 onEmailChanged/onPasswordChanged 回調

3. **lib/screens/auth/views/signup_screen.dart** (202 行)
   - 整合 MemberViewModel
   - 完整錯誤處理
   - Loading 狀態管理
   - 服務條款同意檢查

4. **lib/screens/auth/views/components/sign_up_form.dart** (215 行)
   - 改為 StatefulWidget
   - 新增 4 個回調參數
   - 新增姓名欄位
   - 新增密碼確認欄位
   - 兩個密碼欄位都支援可見性切換
   - 密碼匹配驗證

### 總程式碼變更
- 修改：686 行
- 新增功能：
  - 登入和註冊完整整合 ViewModel
  - 完整錯誤處理（4 種異常類型）
  - Loading 狀態管理
  - 密碼可見性切換
  - 密碼匹配驗證
  - 服務條款同意檢查

---

## 技術亮點

### 1. MVVM 架構

**View (LoginScreen)** ↔ **ViewModel (MemberViewModel)** ↔ **Service (AuthService)** ↔ **API**

- View 只負責 UI 和用戶互動
- ViewModel 處理業務邏輯和狀態管理
- Service 處理 API 呼叫
- 分層清晰，易於測試

### 2. 狀態管理 (Provider)

使用 `Consumer` 模式：
- 自動監聽狀態變化
- UI 自動更新
- 避免手動管理 setState

### 3. 錯誤處理

分層錯誤處理：
- Service 層拋出特定異常（ValidationException, UnauthorizedException 等）
- ViewModel 層捕獲並記錄
- View 層顯示給用戶

### 4. Context 安全性

使用 `mounted` 檢查：
```dart
if (success && mounted) {
  Navigator.pushNamedAndRemoveUntil(...);
}
```

避免 async 操作後使用已 dispose 的 context。

---

## 使用範例

### 登入流程

```dart
// 1. 用戶打開登入畫面
Navigator.pushNamed(context, logInScreenRoute);

// 2. 輸入帳號密碼並點擊登入
// email: user@example.com
// password: password123

// 3. 成功登入後自動導航到首頁
// 4. Token 已儲存到 SharedPreferences
// 5. 用戶資料已載入到 MemberViewModel
```

### 註冊流程

```dart
// 1. 用戶打開註冊畫面
Navigator.pushNamed(context, signUpScreenRoute);

// 2. 輸入資料
// name: John Doe
// email: john@example.com
// password: password123
// password confirmation: password123

// 3. 勾選服務條款同意

// 4. 點擊 Continue 按鈕

// 5. 成功註冊後自動導航到首頁
// 6. Token 已儲存到 SharedPreferences
// 7. 用戶資料已載入到 MemberViewModel
```

### 檢查登入狀態

```dart
final memberViewModel = context.read<MemberViewModel>();

if (memberViewModel.isLoggedIn) {
  print('用戶：${memberViewModel.userName}');
  print('Email：${memberViewModel.userEmail}');
} else {
  // 導航到登入頁面
  Navigator.pushNamed(context, logInScreenRoute);
}
```

### 登出

```dart
final memberViewModel = context.read<MemberViewModel>();
await memberViewModel.logout();

// Token 已清除
// 用戶資料已清除
// 導航回登入頁面
Navigator.pushNamedAndRemoveUntil(
  context,
  logInScreenRoute,
  (route) => false,
);
```

---

## 下一步

**建議優先順序**:

1. **測試認證流程** - 確保登入/註冊/登出都正常運作
2. **（可選）生物辨識** - 如果需要指紋/Face ID 登入
3. **創建完成文檔** - 記錄所有實作細節並標記 Phase 4.1 為完成

---

**Phase 4.1 狀態：🔄 進行中（90% 完成）**

**已完成**:
- ✅ Service 層
- ✅ ViewModel 層
- ✅ 登入畫面整合（LoginScreen + LoginForm）
- ✅ 註冊畫面整合（SignUpScreen + SignUpForm）
- ✅ 完整錯誤處理
- ✅ Loading 狀態管理
- ✅ 密碼可見性切換
- ✅ 服務條款同意檢查
- ✅ Flutter analyze 驗證通過

**待完成**:
- ⏳ 測試認證流程
- ⏳ 生物辨識（可選）
- ⏳ 完成文檔

---

## 備註

- 登入和註冊流程已完整整合 MVVM 架構
- 使用 Provider 進行狀態管理，需要在 `main.dart` 中註冊 `MemberViewModel`
- 所有 API 呼叫都已整合 Token 管理
- 錯誤處理完整，涵蓋 4 種異常類型
- Context 安全性已使用 `mounted` 檢查
- 密碼欄位支援可見性切換
- 註冊流程包含密碼匹配驗證
- 用戶體驗良好

**建議**: 現在可以開始測試登入和註冊功能，確認 API 端點正確且流程完整運作。
