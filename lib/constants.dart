import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

// Just for demo
const productDemoImg1 = "https://i.imgur.com/CGCyp1d.png";
const productDemoImg2 = "https://i.imgur.com/AkzWQuJ.png";
const productDemoImg3 = "https://i.imgur.com/J7mGZ12.png";
const productDemoImg4 = "https://i.imgur.com/q9oF9Yq.png";
const productDemoImg5 = "https://i.imgur.com/MsppAcx.png";
const productDemoImg6 = "https://i.imgur.com/JfyZlnO.png";

// End For demo

const grandisExtendedFont = "Grandis Extended";

// On color 80, 60.... those means opacity

const Color primaryColor = Color(0xFFFF6B35);

const MaterialColor primaryMaterialColor =
    MaterialColor(0xFF9581FF, <int, Color>{
  50: Color(0xFFFFEEE8),
  100: Color(0xFFFFD4C5),
  200: Color(0xFFFFB89E),
  300: Color(0xFFFF9C77),
  400: Color(0xFFFF8656),
  500: Color(0xFFFF6B35),
  600: Color(0xFFFF6330),
  700: Color(0xFFFF5828),
  800: Color(0xFFFF4E22),
  900: Color(0xFFFF3C16),
});

const Color blackColor = Color(0xFF16161E);
const Color blackColor80 = Color(0xFF45454B);
const Color blackColor60 = Color(0xFF737378);
const Color blackColor40 = Color(0xFFA2A2A5);
const Color blackColor20 = Color(0xFFD0D0D2);
const Color blackColor10 = Color(0xFFE8E8E9);
const Color blackColor5 = Color(0xFFF3F3F4);

const Color whiteColor = Colors.white;
const Color whileColor80 = Color(0xFFCCCCCC);
const Color whileColor60 = Color(0xFF999999);
const Color whileColor40 = Color(0xFF666666);
const Color whileColor20 = Color(0xFF333333);
const Color whileColor10 = Color(0xFF191919);
const Color whileColor5 = Color(0xFF0D0D0D);

const Color greyColor = Color(0xFFB8B5C3);
const Color lightGreyColor = Color(0xFFF8F8F9);
const Color darkGreyColor = Color(0xFF1C1C25);
// const Color greyColor80 = Color(0xFFC6C4CF);
// const Color greyColor60 = Color(0xFFD4D3DB);
// const Color greyColor40 = Color(0xFFE3E1E7);
// const Color greyColor20 = Color(0xFFF1F0F3);
// const Color greyColor10 = Color(0xFFF8F8F9);
// const Color greyColor5 = Color(0xFFFBFBFC);

const Color purpleColor = Color(0xFF7B61FF);
const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);

const double defaultPadding = 16.0;
const double defaultBorderRadious = 12.0;
const Duration defaultDuration = Duration(milliseconds: 300);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: '請輸入密碼'),
  MinLengthValidator(6, errorText: '密碼長度至少 6 個字元'),
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: "Enter a valid email address"),
]);

// 手機號碼驗證器（10-15 位數字）
final mobileValidator = MultiValidator([
  RequiredValidator(errorText: '請輸入手機號碼'),
  MinLengthValidator(8, errorText: '手機號碼至少 8 位數字'),
  MaxLengthValidator(15, errorText: '手機號碼最多 15 位數字'),
  PatternValidator(r'^[0-9]+$', errorText: '手機號碼只能包含數字'),
]);

// 驗證碼驗證器（6 位數字）
final verificationCodeValidator = MultiValidator([
  RequiredValidator(errorText: '請輸入驗證碼'),
  MinLengthValidator(6, errorText: '驗證碼為 6 位數字'),
  MaxLengthValidator(6, errorText: '驗證碼為 6 位數字'),
  PatternValidator(r'^[0-9]{6}$', errorText: '驗證碼格式不正確'),
]);

const pasNotMatchErrorText = "passwords do not match";
