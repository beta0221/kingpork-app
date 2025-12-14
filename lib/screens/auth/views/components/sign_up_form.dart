import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tklab_ec_v2/components/country_code_picker.dart';

import '../../../../constants.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
    required this.onNameChanged,
    required this.onCountryCodeChanged,
    required this.onMobileChanged,
    required this.onVerificationCodeChanged,
    required this.onPasswordChanged,
    required this.onSendVerificationCode,
  });

  final GlobalKey<FormState> formKey;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onCountryCodeChanged;
  final ValueChanged<String> onMobileChanged;
  final ValueChanged<String> onVerificationCodeChanged;
  final ValueChanged<String> onPasswordChanged;
  final Future<bool> Function() onSendVerificationCode;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool _obscurePassword = true;
  String _selectedCountryCode = '886';
  bool _isSendingCode = false;
  bool _isCodeSent = false;
  int _countdownSeconds = 60;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _isCodeSent = true;
      _countdownSeconds = 60;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        setState(() {
          _isCodeSent = false;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _handleSendCode() async {
    setState(() {
      _isSendingCode = true;
    });

    try {
      final success = await widget.onSendVerificationCode();
      if (success) {
        _startCountdown();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          // 姓名欄位（可選）
          TextFormField(
            onChanged: widget.onNameChanged,
            onSaved: (name) {
              // Name saved
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              hintText: "姓名（選填）",
              prefixIcon: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Profile.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withValues(alpha: 0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),

          // 手機號碼欄位（帶國碼選擇器）
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 國碼選擇器
              CountryCodePicker(
                selectedCountryCode: _selectedCountryCode,
                onCountryChanged: (country) {
                  setState(() {
                    _selectedCountryCode = country.dialCode;
                  });
                  widget.onCountryCodeChanged(country.dialCode);
                },
                showFlag: true,
                showCountryName: false,
              ),
              const SizedBox(width: defaultPadding / 2),
              // 手機號碼輸入框
              Expanded(
                child: TextFormField(
                  onChanged: widget.onMobileChanged,
                  onSaved: (mobile) {
                    // Mobile saved
                  },
                  validator: mobileValidator.call,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "手機號碼",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: defaultPadding * 0.75),
                      child: SvgPicture.asset(
                        "assets/icons/Call.svg",
                        height: 24,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                            Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!
                                .withValues(alpha: 0.3),
                            BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),

          // 驗證碼欄位（帶發送按鈕）
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  onChanged: widget.onVerificationCodeChanged,
                  onSaved: (code) {
                    // Verification code saved
                  },
                  validator: verificationCodeValidator.call,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: "驗證碼",
                    counterText: '',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: defaultPadding * 0.75),
                      child: SvgPicture.asset(
                        "assets/icons/Lock.svg",
                        height: 24,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                            Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!
                                .withValues(alpha: 0.3),
                            BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: defaultPadding / 2),
              // 發送驗證碼按鈕
              SizedBox(
                width: 90,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isSendingCode || _isCodeSent)
                      ? null
                      : _handleSendCode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: _isSendingCode
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isCodeSent ? '$_countdownSeconds秒' : '發送',
                          style: const TextStyle(fontSize: 14),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),

          // 密碼欄位
          TextFormField(
            onChanged: widget.onPasswordChanged,
            onSaved: (pass) {
              // Password saved
            },
            validator: passwordValidator.call,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: "密碼",
              prefixIcon: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withValues(alpha: 0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withValues(alpha: 0.3),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
