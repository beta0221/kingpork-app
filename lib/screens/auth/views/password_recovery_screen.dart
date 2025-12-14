import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/components/country_code_picker.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/route/route_constants.dart';
import 'package:tklab_ec_v2/viewmodels/member_view_model.dart';
import 'package:tklab_ec_v2/services/api/api_exception.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedCountryCode = '886';
  String _mobile = '';
  String _verificationCode = '';
  bool _isSendingCode = false;
  bool _isCodeSent = false;
  bool _isVerifying = false;
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
    // 基本驗證：檢查手機號碼是否已輸入
    if (_mobile.isEmpty || _mobile.length < 8) {
      _showError('請先輸入有效的手機號碼');
      return;
    }

    setState(() {
      _isSendingCode = true;
    });

    final viewModel = context.read<MemberViewModel>();

    try {
      final success = await viewModel.sendPasswordResetCode(
        countryCode: _selectedCountryCode,
        mobile: _mobile,
      );

      if (success && mounted) {
        _showSuccess('驗證碼已發送');
        _startCountdown();
      } else if (mounted) {
        _showError(viewModel.errorMessage ?? '發送驗證碼失敗');
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showError(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showError('發送驗證碼時發生錯誤：${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  Future<void> _handleVerifyCode() async {
    // 驗證表單
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 檢查是否已發送驗證碼
    if (!_isCodeSent && _countdownSeconds == 60) {
      _showError('請先發送驗證碼');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    final viewModel = context.read<MemberViewModel>();

    try {
      final resetToken = await viewModel.verifyPasswordResetCode(
        countryCode: _selectedCountryCode,
        mobile: _mobile,
        verificationCode: _verificationCode,
      );

      if (resetToken != null && mounted) {
        // 驗證成功，導航到設定新密碼頁面，並傳遞 reset_token
        Navigator.pushNamed(
          context,
          newPasswordScreenRoute,
          arguments: resetToken,
        );
      } else if (mounted) {
        _showError(viewModel.errorMessage ?? '驗證碼驗證失敗');
      }
    } on ValidationException catch (e) {
      if (mounted) {
        _showError(e.getAllErrors().join('\n'));
      }
    } on NetworkException {
      if (mounted) {
        _showError('無網路連線，請檢查網路設定');
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showError(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showError('驗證時發生錯誤：${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: defaultPadding),
                  Text(
                    "密碼復原",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text("請輸入您的手機號碼以復原密碼"),
                  const SizedBox(height: defaultPadding * 2),

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
                        },
                        showFlag: true,
                        showCountryName: false,
                      ),
                      const SizedBox(width: defaultPadding / 2),
                      // 手機號碼輸入框
                      Expanded(
                        child: TextFormField(
                          onChanged: (value) => _mobile = value,
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
                          onChanged: (value) => _verificationCode = value,
                          onSaved: (code) {
                            // Verification code saved
                          },
                          validator: verificationCodeValidator.call,
                          textInputAction: TextInputAction.done,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
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

                  const SizedBox(height: defaultPadding * 2),

                  // 驗證並繼續按鈕
                  Consumer<MemberViewModel>(
                    builder: (context, viewModel, child) {
                      return ElevatedButton(
                        onPressed: _isVerifying ? null : _handleVerifyCode,
                        child: _isVerifying
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text("驗證並繼續"),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
