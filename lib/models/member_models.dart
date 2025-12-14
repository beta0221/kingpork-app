/// 會員認證相關的資料模型
///
/// 包含所有會員系統的請求和回應模型

/// 會員資料模型
class Member {
  final int memberId;
  final String? name;
  final String countryCode;
  final String mobile;
  final String? email;
  final int memberLevel;
  final int? status;
  final String? avatar;
  final String? birthday;
  final int? gender;

  Member({
    required this.memberId,
    this.name,
    required this.countryCode,
    required this.mobile,
    this.email,
    required this.memberLevel,
    this.status,
    this.avatar,
    this.birthday,
    this.gender,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: json['member_id'] as int,
      name: json['name'] as String?,
      countryCode: json['country_code'] as String,
      mobile: json['mobile'] as String,
      email: json['email'] as String?,
      memberLevel: json['member_level'] as int,
      status: json['status'] as int?,
      avatar: json['avatar'] as String?,
      birthday: json['birthday'] as String?,
      gender: json['gender'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'name': name,
      'country_code': countryCode,
      'mobile': mobile,
      'email': email,
      'member_level': memberLevel,
      'status': status,
      'avatar': avatar,
      'birthday': birthday,
      'gender': gender,
    };
  }
}

/// 發送驗證碼請求
class SendVerificationCodeRequest {
  final String countryCode;
  final String mobile;
  final String? email;

  SendVerificationCodeRequest({
    required this.countryCode,
    required this.mobile,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'country_code': countryCode,
      'mobile': mobile,
    };
    if (email != null) {
      json['email'] = email!;
    }
    return json;
  }
}

/// 發送驗證碼回應
class SendVerificationCodeResponse {
  final int s;
  final String msg;
  final String? code; // 僅開發環境返回

  SendVerificationCodeResponse({
    required this.s,
    required this.msg,
    this.code,
  });

  factory SendVerificationCodeResponse.fromJson(Map<String, dynamic> json) {
    return SendVerificationCodeResponse(
      s: json['s'] as int,
      msg: json['msg'] as String,
      code: json['data']?['code'] as String?,
    );
  }

  bool get isSuccess => s == 1;
}

/// 會員註冊請求
class RegisterRequest {
  final String countryCode;
  final String mobile;
  final String password;
  final String verificationCode;
  final String? name;
  final String? email;

  RegisterRequest({
    required this.countryCode,
    required this.mobile,
    required this.password,
    required this.verificationCode,
    this.name,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'country_code': countryCode,
      'mobile': mobile,
      'password': password,
      'verification_code': verificationCode,
    };
    if (name != null) {
      json['name'] = name!;
    }
    if (email != null) {
      json['email'] = email!;
    }
    return json;
  }
}

/// 會員註冊回應資料
class RegisterData {
  final int memberId;
  final String? name;
  final String countryCode;
  final String mobile;

  RegisterData({
    required this.memberId,
    this.name,
    required this.countryCode,
    required this.mobile,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      memberId: json['member_id'] as int,
      name: json['name'] as String?,
      countryCode: json['country_code'] as String,
      mobile: json['mobile'] as String,
    );
  }
}

/// 會員註冊回應
class RegisterResponse {
  final int s;
  final String msg;
  final RegisterData? data;

  RegisterResponse({
    required this.s,
    required this.msg,
    this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      s: json['s'] as int,
      msg: json['msg'] as String,
      data: json['data'] != null ? RegisterData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  bool get isSuccess => s == 1;
}

/// 會員登入請求
class LoginRequest {
  final String countryCode;
  final String mobile;
  final String password;

  LoginRequest({
    required this.countryCode,
    required this.mobile,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'country_code': countryCode,
      'mobile': mobile,
      'password': password,
    };
  }
}

/// 會員登入回應
class LoginResponse {
  final int s;
  final String msg;
  final Member? member;

  LoginResponse({
    required this.s,
    required this.msg,
    this.member,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      s: json['s'] as int,
      msg: json['msg'] as String,
      member: json['data']?['member'] != null
          ? Member.fromJson(json['data']['member'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isSuccess => s == 1;
}

/// 會員登出回應
class LogoutResponse {
  final int s;
  final String msg;

  LogoutResponse({
    required this.s,
    required this.msg,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      s: json['s'] as int,
      msg: json['msg'] as String,
    );
  }

  bool get isSuccess => s == 1;
}

/// 取得會員資訊回應
class MemberInfoResponse {
  final int s;
  final String? msg;
  final Member? member;

  MemberInfoResponse({
    required this.s,
    this.msg,
    this.member,
  });

  factory MemberInfoResponse.fromJson(Map<String, dynamic> json) {
    return MemberInfoResponse(
      s: json['s'] as int,
      msg: json['msg'] as String?,
      member: json['data'] != null ? Member.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  bool get isSuccess => s == 1;
}

/// 刪除帳號回應
class DeleteAccountResponse {
  final int s;
  final String msg;

  DeleteAccountResponse({
    required this.s,
    required this.msg,
  });

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAccountResponse(
      s: json['s'] as int,
      msg: json['msg'] as String,
    );
  }

  bool get isSuccess => s == 1;
}

/// 發送密碼重設驗證碼請求
class SendPasswordResetCodeRequest {
  final String countryCode;
  final String mobile;
  final String? email;

  SendPasswordResetCodeRequest({
    required this.countryCode,
    required this.mobile,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'country_code': countryCode,
      'mobile': mobile,
    };
    if (email != null) {
      json['email'] = email!;
    }
    return json;
  }
}

/// 發送密碼重設驗證碼回應
class SendPasswordResetCodeResponse {
  final int s;
  final String msg;
  final String? code; // 僅開發環境返回

  SendPasswordResetCodeResponse({
    required this.s,
    required this.msg,
    this.code,
  });

  factory SendPasswordResetCodeResponse.fromJson(Map<String, dynamic> json) {
    return SendPasswordResetCodeResponse(
      s: json['s'] as int,
      msg: json['msg'] as String,
      code: json['data']?['code'] as String?,
    );
  }

  bool get isSuccess => s == 1;
}

/// 驗證密碼重設驗證碼請求
class VerifyPasswordResetCodeRequest {
  final String countryCode;
  final String mobile;
  final String verificationCode;
  final String? email;

  VerifyPasswordResetCodeRequest({
    required this.countryCode,
    required this.mobile,
    required this.verificationCode,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'country_code': countryCode,
      'mobile': mobile,
      'verification_code': verificationCode,
    };
    if (email != null) {
      json['email'] = email!;
    }
    return json;
  }
}

/// 驗證密碼重設驗證碼回應
class VerifyPasswordResetCodeResponse {
  final int s;
  final String msg;
  final String? resetToken;
  final int? expiresIn;

  VerifyPasswordResetCodeResponse({
    required this.s,
    required this.msg,
    this.resetToken,
    this.expiresIn,
  });

  factory VerifyPasswordResetCodeResponse.fromJson(Map<String, dynamic> json) {
    return VerifyPasswordResetCodeResponse(
      s: json['s'] as int,
      msg: json['msg'] as String,
      resetToken: json['data']?['reset_token'] as String?,
      expiresIn: json['data']?['expires_in'] as int?,
    );
  }

  bool get isSuccess => s == 1;
}

/// 重設密碼請求
class ResetPasswordRequest {
  final String resetToken;
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequest({
    required this.resetToken,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'reset_token': resetToken,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}

/// 重設密碼回應
class ResetPasswordResponse {
  final int s;
  final String msg;

  ResetPasswordResponse({
    required this.s,
    required this.msg,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      s: json['s'] as int,
      msg: json['msg'] as String,
    );
  }

  bool get isSuccess => s == 1;
}

/// 解密手機號碼請求（除錯用）
class DecryptMobileRequest {
  final String encryptedText;

  DecryptMobileRequest({required this.encryptedText});

  Map<String, dynamic> toJson() {
    return {
      'encrypted_text': encryptedText,
    };
  }
}

/// 解密手機號碼回應
class DecryptMobileResponse {
  final int s;
  final String msg;
  final String? decrypted;

  DecryptMobileResponse({
    required this.s,
    required this.msg,
    this.decrypted,
  });

  factory DecryptMobileResponse.fromJson(Map<String, dynamic> json) {
    return DecryptMobileResponse(
      s: json['s'] as int,
      msg: json['msg'] as String,
      decrypted: json['data']?['decrypted'] as String?,
    );
  }

  bool get isSuccess => s == 1;
}

/// 會員等級枚舉
enum MemberLevel {
  tkClub(1, 'TK俱樂部'),
  tkGold(2, 'TK金卡'),
  tkPlatinum(4, 'TK白金卡'),
  tkBlackDiamond(8, 'TK黑鑽卡');

  final int value;
  final String displayName;

  const MemberLevel(this.value, this.displayName);

  static MemberLevel fromValue(int value) {
    return MemberLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => MemberLevel.tkClub,
    );
  }
}

/// 會員狀態枚舉
enum MemberStatus {
  normal(1, '正常'),
  suspended(2, '停權'),
  paymentRestricted(4, '付款受限'),
  blacklisted(8, '黑名單'),
  deleted(16, '已刪除');

  final int value;
  final String displayName;

  const MemberStatus(this.value, this.displayName);

  static MemberStatus fromValue(int value) {
    return MemberStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => MemberStatus.normal,
    );
  }
}

/// 性別枚舉
enum Gender {
  male(1, '男'),
  female(2, '女'),
  other(4, '其他');

  final int value;
  final String displayName;

  const Gender(this.value, this.displayName);

  static Gender? fromValue(int? value) {
    if (value == null) return null;
    return Gender.values.firstWhere(
      (gender) => gender.value == value,
      orElse: () => Gender.other,
    );
  }
}
