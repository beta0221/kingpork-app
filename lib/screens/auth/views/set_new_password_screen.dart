import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/route/route_constants.dart';
import 'package:tklab_ec_v2/viewmodels/member_view_model.dart';
import 'package:tklab_ec_v2/services/api/api_exception.dart';

import 'components/new_pass_form.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _password = '';
  String _confirmPassword = '';
  bool _isResetting = false;

  Future<void> _handleResetPassword(String resetToken) async {
    // 驗證表單
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isResetting = true;
    });

    final viewModel = context.read<MemberViewModel>();

    try {
      final success = await viewModel.resetPassword(
        resetToken: resetToken,
        password: _password,
        passwordConfirmation: _confirmPassword,
      );

      if (success && mounted) {
        // 重設密碼成功，導航到完成畫面
        Navigator.pushNamedAndRemoveUntil(
          context,
          doneResetPasswordScreenRoute,
          (route) => false,
        );
      } else if (mounted) {
        _showError(viewModel.errorMessage ?? '重設密碼失敗');
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
        _showError('重設密碼時發生錯誤：${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResetting = false;
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

  @override
  Widget build(BuildContext context) {
    // 從路由參數獲取 reset_token
    final resetToken = ModalRoute.of(context)?.settings.arguments as String?;

    // 如果沒有 reset_token，顯示錯誤並返回
    if (resetToken == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showError('無效的重設連結，請重新操作');
        Navigator.pop(context);
      });
    }

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "設定新密碼",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: defaultPadding / 2),
              const Text("您的新密碼必須與先前使用的密碼不同。"),
              const SizedBox(height: defaultPadding * 2),
              NewPassForm(
                formKey: _formKey,
                onPasswordChanged: (value) => _password = value,
                onConfirmPasswordChanged: (value) => _confirmPassword = value,
              ),
              const Spacer(),
              Consumer<MemberViewModel>(
                builder: (context, viewModel, child) {
                  return ElevatedButton(
                    onPressed: (_isResetting || resetToken == null)
                        ? null
                        : () => _handleResetPassword(resetToken),
                    child: _isResetting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text("更改密碼"),
                  );
                },
              ),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}
