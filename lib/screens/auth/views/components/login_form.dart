import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tklab_ec_v2/components/country_code_picker.dart';
import '../../../../constants.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({
    super.key,
    required this.formKey,
    required this.onCountryCodeChanged,
    required this.onMobileChanged,
    required this.onPasswordChanged,
  });

  final GlobalKey<FormState> formKey;
  final ValueChanged<String> onCountryCodeChanged;
  final ValueChanged<String> onMobileChanged;
  final ValueChanged<String> onPasswordChanged;

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  bool _obscurePassword = true;
  String _selectedCountryCode = '886';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
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
                      BlendMode.srcIn),
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
