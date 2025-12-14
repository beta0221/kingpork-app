import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/components/network_image_with_loader.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/route/route_constants.dart';
import 'package:tklab_ec_v2/viewmodels/member_view_model.dart';
import 'package:tklab_ec_v2/services/api/api_exception.dart';

import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _countryCode = '886';
  String _mobile = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

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
                      "歡迎回來！",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    const Text(
                      "使用您的手機號碼登入。",
                    ),
                    const SizedBox(height: defaultPadding),
                    LogInForm(
                      formKey: _formKey,
                      onCountryCodeChanged: (value) => _countryCode = value,
                      onMobileChanged: (value) => _mobile = value,
                      onPasswordChanged: (value) => _password = value,
                    ),
                    Align(
                      child: TextButton(
                        child: const Text("忘記密碼"),
                        onPressed: () {
                          Navigator.pushNamed(
                              context, passwordRecoveryScreenRoute);
                        },
                      ),
                    ),
                    SizedBox(
                      height: size.height > 700
                          ? size.height * 0.1
                          : defaultPadding,
                    ),
                    Consumer<MemberViewModel>(
                      builder: (context, viewModel, child) {
                        return ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => _handleLogin(viewModel),
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
                              : const Text("登入"),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("還沒有帳號？"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, signUpScreenRoute);
                          },
                          child: const Text("註冊"),
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

  Future<void> _handleLogin(MemberViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final success = await viewModel.login(
        countryCode: _countryCode,
        mobile: _mobile,
        password: _password,
      );

      if (success && mounted) {
        // 登入成功，導航到首頁
        Navigator.pushNamedAndRemoveUntil(
          context,
          entryPointScreenRoute,
          (route) => false,
        );
      } else if (mounted) {
        // 登入失敗，顯示錯誤訊息
        _showError(viewModel.errorMessage ?? '登入失敗，請稍後再試');
      }
    } on ValidationException catch (e) {
      if (mounted) {
        _showError(e.getAllErrors().join('\n'));
      }
    } on NetworkException {
      if (mounted) {
        _showError('無網路連線，請檢查網路設定');
      }
    } on UnauthorizedException {
      if (mounted) {
        _showError('帳號或密碼錯誤');
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showError(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showError('登入時發生錯誤：${e.toString()}');
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
}
