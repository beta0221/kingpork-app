import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:tklab_ec_v2/components/network_image_with_loader.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/viewmodels/base_view_model.dart';
import 'package:tklab_ec_v2/viewmodels/member_view_model.dart';

import 'components/user_info_form.dart';

class EditUserInfoScreen extends StatefulWidget {
  const EditUserInfoScreen({super.key});

  @override
  State<EditUserInfoScreen> createState() => _EditUserInfoScreenState();
}

class _EditUserInfoScreenState extends State<EditUserInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<UserInfoFormState> _formStateKey = GlobalKey<UserInfoFormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 載入會員資料
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<MemberViewModel>();
      if (viewModel.currentMember == null) {
        viewModel.loadMemberProfile();
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    // 驗證表單
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // 取得表單資料
    final formData = _formStateKey.currentState?.getFormData();
    if (formData == null) return;

    setState(() => _isSubmitting = true);

    final viewModel = context.read<MemberViewModel>();
    final success = await viewModel.updateProfile(
      name: formData.name,
      email: formData.email,
      birthday: formData.birthday,
      gender: formData.gender,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('個人資料已更新'),
            backgroundColor: successColor,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? '更新失敗'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("個人資料"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/info.svg",
              colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn),
            ),
          )
        ],
      ),
      body: Consumer<MemberViewModel>(
        builder: (context, viewModel, child) {
          // 顯示載入中
          if (viewModel.state == ViewState.loading && viewModel.currentMember == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 顯示錯誤
          if (viewModel.state == ViewState.error && viewModel.currentMember == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.errorMessage ?? '載入失敗',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: () => viewModel.loadMemberProfile(),
                    child: const Text('重試'),
                  ),
                ],
              ),
            );
          }

          final member = viewModel.currentMember;
          final avatarUrl = member?.avatar;

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              child: avatarUrl != null && avatarUrl.isNotEmpty
                                  ? NetworkImageWithLoader(
                                      avatarUrl,
                                      radius: 100,
                                    )
                                  : ClipOval(
                                      child: SvgPicture.asset(
                                        "assets/icons/user-circle-svgrepo-com.svg",
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: -14,
                              right: -14,
                              child: SizedBox(
                                height: 56,
                                width: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: 實作頭像編輯功能
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    side: BorderSide(width: 4, color: Theme.of(context).scaffoldBackgroundColor),
                                  ),
                                  child: SvgPicture.asset(
                                    "assets/icons/Edit-Bold.svg",
                                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        TextButton(
                          onPressed: () {
                            // TODO: 實作頭像編輯功能
                          },
                          child: const Text("編輯照片"),
                        ),
                        const SizedBox(height: defaultPadding),
                        UserInfoForm(
                          key: _formStateKey,
                          member: member,
                          formKey: _formKey,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text("完成"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
