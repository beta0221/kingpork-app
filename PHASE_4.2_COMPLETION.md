# Phase 4.2 - 用戶資料整合 完成總結

## 完成日期
2025-01-06

## 概述

Phase 4.2 完成了用戶資料顯示畫面與 MemberViewModel 的整合，包括 ProfileScreen 和 UserInfoScreen。實作了完整的登出流程，並確保所有用戶相關畫面都能正確顯示來自認證系統的用戶資料。

---

## 實作內容

### 1. ProfileCard 元件更新

**檔案位置**: `lib/screens/profile/views/components/profile_card.dart`

**程式碼行數**: 117 行（原 80 行，新增 37 行）

**主要變更**:

1. **新增 Provider 整合**:
   - 引入 `provider` package 和 `MemberViewModel`
   - 新增 `useViewModel` 參數，允許從 ViewModel 獲取資料

2. **欄位改為可選**:
   - `name`, `email`, `imageSrc` 改為可選參數（`String?`）
   - 當 `useViewModel=true` 時，從 MemberViewModel 獲取資料
   - 當 `useViewModel=false` 時，使用手動傳入的參數（向後兼容）

3. **實作細節**:

```dart
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    this.name,              // 改為可選
    this.email,             // 改為可選
    this.imageSrc,          // 改為可選
    this.proLableText = "Pro",
    this.isPro = false,
    this.press,
    this.isShowHi = true,
    this.isShowArrow = true,
    this.useViewModel = false,  // 新增參數
  });

  final String? name, email, imageSrc;
  final bool useViewModel;

  @override
  Widget build(BuildContext context) {
    if (useViewModel) {
      return Consumer<MemberViewModel>(
        builder: (context, viewModel, child) {
          final displayName = viewModel.userName ?? name ?? "Guest";
          final displayEmail = viewModel.userEmail ?? email ?? "";
          final displayImage = imageSrc ?? "https://i.imgur.com/IXnwbLk.png";

          return _buildCard(...);
        },
      );
    }

    return _buildCard(...);
  }

  Widget _buildCard({...}) {
    // 原有的 UI 邏輯
  }
}
```

**優點**:
- ✅ 向後兼容：現有使用 ProfileCard 的地方無需修改
- ✅ 靈活性：可選擇使用 ViewModel 或手動傳入參數
- ✅ 單一責任：UI 邏輯與資料來源分離

---

### 2. ProfileScreen 更新

**檔案位置**: `lib/screens/profile/views/profile_screen.dart`

**程式碼行數**: 251 行（原 180 行，新增 71 行）

**主要變更**:

1. **整合 MemberViewModel**:
   - 引入 Provider 監聽用戶登入狀態
   - ProfileCard 使用 `useViewModel=true`
   - 根據登入狀態顯示不同按鈕

2. **登入狀態條件渲染**:

```dart
// ProfileCard 使用 ViewModel
const ProfileCard(
  useViewModel: true,
  press: null,
)

// 根據登入狀態顯示按鈕
Consumer<MemberViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.isLoggedIn) {
      return OutlinedButton(
        onPressed: () {
          Navigator.pushNamed(context, userInfoScreenRoute);
        },
        child: const Text("View Profile"),
      );
    }
    return OutlinedButton(
      onPressed: () {
        Navigator.pushNamed(context, logInScreenRoute);
      },
      child: const Text("Log In"),
    );
  },
)
```

3. **登出功能實作**:

```dart
Future<void> _handleLogout(
    BuildContext context, MemberViewModel viewModel) async {
  // 顯示確認對話框
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Log Out"),
      content: const Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: errorColor),
          child: const Text("Log Out"),
        ),
      ],
    ),
  );

  if (shouldLogout == true && context.mounted) {
    // 執行登出
    await viewModel.logout();

    if (context.mounted) {
      // 顯示成功訊息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You have been logged out successfully"),
          duration: Duration(seconds: 2),
        ),
      );

      // 導航到登入頁面
      Navigator.pushNamedAndRemoveUntil(
        context,
        logInScreenRoute,
        (route) => false,
      );
    }
  }
}
```

4. **登出按鈕條件顯示**:

```dart
Consumer<MemberViewModel>(
  builder: (context, viewModel, child) {
    if (!viewModel.isLoggedIn) {
      return const SizedBox.shrink();  // 未登入時隱藏
    }

    return ListTile(
      onTap: () => _handleLogout(context, viewModel),
      leading: SvgPicture.asset("assets/icons/Logout.svg", ...),
      title: const Text("Log Out", ...),
    );
  },
)
```

**功能特點**:
- ✅ 登出前顯示確認對話框
- ✅ 登出後清除 Token 和用戶資料
- ✅ 自動導航到登入頁面
- ✅ 顯示成功訊息
- ✅ Context 安全性檢查（`mounted`）
- ✅ 未登入時隱藏登出按鈕

---

### 3. UserInfoScreen 更新

**檔案位置**: `lib/screens/user_info/views/user_info_screen.dart`

**程式碼行數**: 104 行（原 74 行，新增 30 行）

**主要變更**:

1. **整合 MemberViewModel**:
   - 使用 `Consumer<MemberViewModel>` 包裹整個 body
   - 根據登入狀態顯示不同內容

2. **未登入狀態處理**:

```dart
Consumer<MemberViewModel>(
  builder: (context, viewModel, child) {
    if (!viewModel.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Please log in to view your profile"),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, logInScreenRoute);
              },
              child: const Text("Log In"),
            ),
          ],
        ),
      );
    }

    // 已登入：顯示用戶資料
    ...
  },
)
```

3. **動態資料顯示**:

```dart
final user = viewModel.currentUser;
final name = user?.name ?? "N/A";
final email = user?.email ?? "N/A";
final phone = user?.phone ?? "Not provided";

return SingleChildScrollView(
  child: Column(
    children: [
      const ProfileCard(
        useViewModel: true,
        isShowHi: false,
        isShowArrow: false,
      ),
      UserInfoListTile(
        leadingText: "Name",
        trailingText: name,
      ),
      UserInfoListTile(
        leadingText: "Phone number",
        trailingText: phone,
      ),
      UserInfoListTile(
        leadingText: "Email",
        trailingText: email,
      ),
      if (user?.bonus != null)
        UserInfoListTile(
          leadingText: "Bonus Points",
          trailingText: "${user!.bonus}",
        ),
      // ... 其他欄位
    ],
  ),
);
```

**資料來源**:
- `name` ← `user.name`
- `email` ← `user.email`
- `phone` ← `user.phone`
- `bonus` ← `user.bonus`（可選，僅在有值時顯示）

**功能特點**:
- ✅ 未登入時顯示登入提示
- ✅ 已登入時顯示完整用戶資料
- ✅ 使用 null-aware 操作符防止錯誤
- ✅ 動態顯示 Bonus Points（僅在有值時）
- ✅ ProfileCard 使用 ViewModel 資料

---

## 檔案修改清單

### 已修改的檔案（3 個）

1. **lib/screens/profile/views/components/profile_card.dart** (117 行)
   - 新增 Provider 整合
   - 新增 `useViewModel` 參數
   - 欄位改為可選（向後兼容）
   - 新增 `_buildCard()` 輔助方法

2. **lib/screens/profile/views/profile_screen.dart** (251 行)
   - 整合 MemberViewModel
   - 實作登出功能（含確認對話框）
   - 根據登入狀態條件渲染
   - 新增 `_handleLogout()` 方法

3. **lib/screens/user_info/views/user_info_screen.dart** (104 行)
   - 整合 MemberViewModel
   - 未登入時顯示登入提示
   - 動態顯示用戶資料
   - 新增 Bonus Points 欄位（條件顯示）

### 總程式碼變更
- 修改：472 行
- 新增功能：
  - ViewModel 整合（3 個畫面）
  - 登出流程（含確認對話框）
  - 登入狀態條件渲染
  - 動態用戶資料顯示
  - Context 安全性檢查

---

## 技術亮點

### 1. 向後兼容設計

ProfileCard 的更新保持了向後兼容性：

```dart
// 舊用法（仍然有效）
ProfileCard(
  name: "Sepide",
  email: "theflutterway@gmail.com",
  imageSrc: "https://i.imgur.com/IXnwbLk.png",
)

// 新用法（使用 ViewModel）
ProfileCard(
  useViewModel: true,
)
```

**優點**:
- 現有代碼無需修改
- 逐步遷移到 ViewModel
- 減少破壞性變更

### 2. 登出流程設計

**流程**:
1. 用戶點擊 "Log Out" 按鈕
2. 顯示確認對話框
3. 用戶確認後執行 `viewModel.logout()`
4. 清除 Token 和用戶資料
5. 顯示成功訊息
6. 導航到登入頁面（清除所有導航歷史）

**安全性**:
- ✅ 雙重確認（對話框）
- ✅ Context 安全檢查（`mounted`）
- ✅ 清除所有導航歷史（`pushNamedAndRemoveUntil`）

### 3. 登入狀態管理

使用 `Consumer<MemberViewModel>` 實現響應式 UI：

```dart
Consumer<MemberViewModel>(
  builder: (context, viewModel, child) {
    if (!viewModel.isLoggedIn) {
      // 顯示登入提示或登入按鈕
    } else {
      // 顯示用戶資料
    }
  },
)
```

**優點**:
- 自動監聽登入狀態變化
- UI 自動更新
- 無需手動管理 setState

### 4. 空值安全處理

所有用戶資料讀取都使用 null-aware 操作符：

```dart
final name = user?.name ?? "N/A";
final email = user?.email ?? "N/A";
final phone = user?.phone ?? "Not provided";

if (user?.bonus != null) {
  UserInfoListTile(
    leadingText: "Bonus Points",
    trailingText: "${user!.bonus}",
  ),
}
```

**優點**:
- 防止空指標錯誤
- 提供預設值
- 條件顯示可選欄位

---

## 使用範例

### 查看個人資料

```dart
// 1. 用戶登入後點擊 ProfileCard
Navigator.pushNamed(context, userInfoScreenRoute);

// 2. UserInfoScreen 自動顯示用戶資料
// - 名稱: viewModel.currentUser.name
// - Email: viewModel.currentUser.email
// - 電話: viewModel.currentUser.phone
// - Bonus: viewModel.currentUser.bonus
```

### 登出流程

```dart
// 1. 用戶在 ProfileScreen 點擊 "Log Out"

// 2. 顯示確認對話框
// "Are you sure you want to log out?"
// [Cancel] [Log Out]

// 3. 用戶確認後執行登出
await viewModel.logout();

// 4. 清除 Token 和資料

// 5. 顯示成功訊息
// "You have been logged out successfully"

// 6. 導航到登入頁面
Navigator.pushNamedAndRemoveUntil(
  context,
  logInScreenRoute,
  (route) => false,
);
```

### 未登入訪問

```dart
// 1. 未登入用戶訪問 UserInfoScreen

// 2. 顯示登入提示
// "Please log in to view your profile"
// [Log In] 按鈕

// 3. 點擊按鈕後導航到登入頁面
Navigator.pushNamed(context, logInScreenRoute);
```

---

## 測試建議

### 功能測試

**ProfileCard 元件**:
- [ ] 測試 `useViewModel=false` 時使用手動參數
- [ ] 測試 `useViewModel=true` 時從 ViewModel 獲取資料
- [ ] 測試未登入時顯示 "Guest"
- [ ] 測試 `isShowHi`, `isShowArrow`, `isPro` 參數

**ProfileScreen**:
- [ ] 測試登入後顯示 "View Profile" 按鈕
- [ ] 測試未登入時顯示 "Log In" 按鈕
- [ ] 測試登出確認對話框
- [ ] 測試點擊 "Cancel" 不執行登出
- [ ] 測試點擊 "Log Out" 執行登出
- [ ] 測試登出後導航到登入頁面
- [ ] 測試未登入時隱藏 "Log Out" 按鈕

**UserInfoScreen**:
- [ ] 測試未登入時顯示登入提示
- [ ] 測試登入後顯示完整用戶資料
- [ ] 測試所有欄位正確顯示
- [ ] 測試 Bonus Points 條件顯示
- [ ] 測試空值安全處理

### 整合測試

- [ ] 測試完整登入 → 查看資料 → 登出流程
- [ ] 測試未登入 → 訪問 UserInfoScreen → 登入 → 返回
- [ ] 測試登出後 ProfileCard 顯示 "Guest"
- [ ] 測試登出後所有受保護頁面正確處理

---

## 與其他 Phase 的關聯

### 依賴的 Phase

- **Phase 4.1** - 認證流程
  - 依賴 `MemberViewModel.login()`
  - 依賴 `MemberViewModel.signup()`
  - 依賴 `MemberViewModel.logout()`
  - 依賴 `MemberViewModel.isLoggedIn`
  - 依賴 `MemberViewModel.currentUser`

- **Phase 2.1** - API 層
  - 依賴 `AuthService.logout()`
  - 依賴 Token 管理

- **Phase 2.2** - ViewModel 層
  - 依賴 `BaseViewModel`
  - 依賴 Provider 狀態管理

### 影響的 Phase

- **Phase 4.3** - 用戶資料編輯（待實作）
  - ProfileScreen 提供導航到編輯頁面
  - UserInfoScreen 提供 "Edit" 按鈕

---

## 已知限制

1. **ProfileCard 圖片**:
   - 目前使用預設圖片 URL
   - User 模型沒有 `profileImage` 欄位
   - 未來需要新增圖片上傳功能

2. **用戶資料欄位**:
   - Date of birth: 未實作（顯示 "Not provided"）
   - Gender: 未實作（顯示 "Not provided"）
   - 需要擴展 User 模型和 API

3. **密碼變更**:
   - UserInfoScreen 提供 "Change password" 按鈕
   - 實際功能在其他畫面實作

---

## 下一步

**Phase 4.3 - 用戶資料編輯（建議）**:

1. **編輯個人資料畫面**:
   - 更新 `edit_user_info_screen.dart`
   - 整合 `MemberViewModel.updateProfile()`
   - 表單驗證
   - 成功後更新 ViewModel 狀態

2. **密碼變更流程**:
   - 整合現有的密碼變更畫面
   - 實作 `changePassword()` API
   - 驗證舊密碼
   - 更新新密碼

3. **圖片上傳**:
   - 實作圖片選擇和上傳
   - 更新 User 模型新增 `profileImage` 欄位
   - 整合到 ProfileCard

---

## 總結

Phase 4.2 成功整合了用戶資料顯示功能：

### ✅ 已完成

- ProfileCard 元件支援 ViewModel（向後兼容）
- ProfileScreen 整合登入狀態和登出功能
- UserInfoScreen 動態顯示用戶資料
- 完整的登出流程（含確認對話框）
- 登入狀態條件渲染
- 所有文件通過 `flutter analyze`

### 📊 程式碼統計

- 修改檔案：3 個
- 總行數：472 行
- 新增功能：6 項
- 測試項目：20+ 項

### 🎯 下一階段建議

繼續實作 **Phase 4.3 - 用戶資料編輯**，完善整個用戶管理模組。

---

**Phase 4.2 狀態：✅ 完成**

**完成時間：2025-01-06**
