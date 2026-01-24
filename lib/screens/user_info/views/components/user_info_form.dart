import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';
import '../../../../models/member_models.dart';

/// 個人資料表單資料
class UserInfoFormData {
  final String? name;
  final String? email;
  final String? birthday;
  final int? gender;

  UserInfoFormData({
    this.name,
    this.email,
    this.birthday,
    this.gender,
  });
}

class UserInfoForm extends StatefulWidget {
  final Member? member;
  final GlobalKey<FormState>? formKey;
  final ValueChanged<UserInfoFormData>? onChanged;

  const UserInfoForm({
    super.key,
    this.member,
    this.formKey,
    this.onChanged,
  });

  @override
  State<UserInfoForm> createState() => UserInfoFormState();
}

class UserInfoFormState extends State<UserInfoForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _birthdayController;
  late final TextEditingController _mobileController;
  int? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.name ?? '');
    _emailController = TextEditingController(text: widget.member?.email ?? '');
    _birthdayController = TextEditingController(text: widget.member?.birthday ?? '');
    _mobileController = TextEditingController(
      text: widget.member != null ? '+${widget.member!.countryCode}-${widget.member!.mobile}' : '',
    );
    _selectedGender = widget.member?.gender;
  }

  @override
  void didUpdateWidget(covariant UserInfoForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 當 member 資料更新時，同步更新控制器
    if (widget.member != oldWidget.member && widget.member != null) {
      _nameController.text = widget.member?.name ?? '';
      _emailController.text = widget.member?.email ?? '';
      _birthdayController.text = widget.member?.birthday ?? '';
      _mobileController.text = '+${widget.member!.countryCode}-${widget.member!.mobile}';
      _selectedGender = widget.member?.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  /// 取得表單資料
  UserInfoFormData getFormData() {
    return UserInfoFormData(
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      birthday: _birthdayController.text.trim().isNotEmpty ? _birthdayController.text.trim() : null,
      gender: _selectedGender,
    );
  }

  void _notifyChange() {
    widget.onChanged?.call(getFormData());
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _parseBirthday() ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
      _notifyChange();
    }
  }

  DateTime? _parseBirthday() {
    if (_birthdayController.text.isEmpty) return null;
    try {
      return DateTime.parse(_birthdayController.text);
    } catch (_) {
      return null;
    }
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('男'),
                trailing: _selectedGender == Gender.male.value ? const Icon(Icons.check, color: primaryColor) : null,
                onTap: () {
                  setState(() => _selectedGender = Gender.male.value);
                  _notifyChange();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('女'),
                trailing: _selectedGender == Gender.female.value ? const Icon(Icons.check, color: primaryColor) : null,
                onTap: () {
                  setState(() => _selectedGender = Gender.female.value);
                  _notifyChange();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('其他'),
                trailing: _selectedGender == Gender.other.value ? const Icon(Icons.check, color: primaryColor) : null,
                onTap: () {
                  setState(() => _selectedGender = Gender.other.value);
                  _notifyChange();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getGenderDisplayText() {
    final gender = Gender.fromValue(_selectedGender);
    return gender?.displayName ?? '請選擇性別';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          children: [
            // 姓名欄位
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _notifyChange(),
              decoration: InputDecoration(
                labelText: '姓名',
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                  child: SvgPicture.asset(
                    "assets/icons/Profile.svg",
                    colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn),
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
              validator: (value) {
                if (value != null && value.length > 100) {
                  return '姓名不能超過 100 個字元';
                }
                return null;
              },
            ),
            const SizedBox(height: defaultPadding),

            // Email 欄位
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _notifyChange(),
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                  child: SvgPicture.asset(
                    "assets/icons/Message.svg",
                    colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn),
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return '請輸入有效的 Email 格式';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: defaultPadding),

            // 生日欄位（唯讀，點擊選擇）
            TextFormField(
              controller: _birthdayController,
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                labelText: '生日',
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                  child: SvgPicture.asset(
                    "assets/icons/Calender.svg",
                    colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn),
                    height: 24,
                    width: 24,
                  ),
                ),
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
            ),
            const SizedBox(height: defaultPadding),

            // 性別欄位（點擊選擇）
            InkWell(
              onTap: _showGenderPicker,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '性別',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                    child: Icon(
                      Icons.person_outline,
                      color: Theme.of(context).iconTheme.color,
                      size: 24,
                    ),
                  ),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _getGenderDisplayText(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _selectedGender == null ? Theme.of(context).hintColor : null,
                      ),
                ),
              ),
            ),
            const SizedBox(height: defaultPadding),

            // 手機號碼欄位（唯讀）
            TextFormField(
              controller: _mobileController,
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: '手機號碼（無法修改）',
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                  child: SvgPicture.asset(
                    "assets/icons/Call.svg",
                    height: 24,
                    width: 24,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).disabledColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
