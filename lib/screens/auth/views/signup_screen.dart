import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/components/network_image_with_loader.dart';
import 'package:tklab_ec_v2/screens/auth/views/components/sign_up_form.dart';
import 'package:tklab_ec_v2/route/route_constants.dart';
import 'package:tklab_ec_v2/viewmodels/member_view_model.dart';
import 'package:tklab_ec_v2/services/api/api_exception.dart';

import '../../../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _name;
  String _countryCode = '886';
  String _mobile = '';
  String _verificationCode = '';
  String _password = '';
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 3,
                child: NetworkImageWithLoader(
                    "https://img.tklab.com.tw/uploads/mobile_index/6/3/61a6e8e8e1a2e482c7ed5f05bd87449e94ea6ff3_m.webp",
                    radius: 0),
              ),
              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "開始使用！",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    const Text(
                      "請輸入您的手機號碼以建立帳號。",
                    ),
                    const SizedBox(height: defaultPadding),
                    SignUpForm(
                      formKey: _formKey,
                      onNameChanged: (value) => _name = value.isEmpty ? null : value,
                      onCountryCodeChanged: (value) => _countryCode = value,
                      onMobileChanged: (value) => _mobile = value,
                      onVerificationCodeChanged: (value) => _verificationCode = value,
                      onPasswordChanged: (value) => _password = value,
                      onSendVerificationCode: () => _handleSendVerificationCode(),
                    ),
                    const SizedBox(height: defaultPadding),
                    Row(
                      children: [
                        Checkbox(
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                          value: _agreedToTerms,
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: "我同意",
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(
                                          context, termsOfServicesScreenRoute);
                                    },
                                  text: "服務條款",
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const TextSpan(
                                  text: "與隱私政策。",
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: defaultPadding * 2),
                    Consumer<MemberViewModel>(
                      builder: (context, viewModel, child) {
                        return ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => _handleSignup(viewModel),
                          child: viewModel.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text("繼續"),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("已經有帳號了？"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, logInScreenRoute);
                          },
                          child: const Text("登入"),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _handleSendVerificationCode() async {
    // 基本驗證：檢查手機號碼是否已輸入
    if (_mobile.isEmpty || _mobile.length < 8) {
      _showError('請先輸入有效的手機號碼');
      return false;
    }

    final viewModel = context.read<MemberViewModel>();

    try {
      final success = await viewModel.sendVerificationCode(
        countryCode: _countryCode,
        mobile: _mobile,
      );

      if (success && mounted) {
        _showSuccess('驗證碼已發送');
        return true;
      } else if (mounted) {
        _showError(viewModel.errorMessage ?? '發送驗證碼失敗');
        return false;
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showError(e.message);
      }
      return false;
    } catch (e) {
      if (mounted) {
        _showError('發送驗證碼時發生錯誤：${e.toString()}');
      }
      return false;
    }

    return false;
  }

  Future<void> _handleSignup(MemberViewModel viewModel) async {
    // 驗證表單
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 檢查是否同意條款
    if (!_agreedToTerms) {
      _showError('請同意服務條款與隱私政策');
      return;
    }

    try {
      final success = await viewModel.register(
        countryCode: _countryCode,
        mobile: _mobile,
        verificationCode: _verificationCode,
        password: _password,
        name: _name,
      );

      if (success && mounted) {
        // 註冊成功，導航到首頁
        Navigator.pushNamedAndRemoveUntil(
          context,
          entryPointScreenRoute,
          (route) => false,
        );
      } else if (mounted) {
        // 註冊失敗，顯示錯誤訊息
        _showError(viewModel.errorMessage ?? '註冊失敗，請稍後再試');
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
        _showError('註冊時發生錯誤：${e.toString()}');
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
}
