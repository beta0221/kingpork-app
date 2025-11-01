import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/components/custom_modal_bottom_sheet.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/route/screen_export.dart';
import 'package:tklab_ec_v2/screens/auth/views/components/sign_up_verification_otp_form.dart';

class SignUpVerificationScreen extends StatelessWidget {
  const SignUpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "驗證碼",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: defaultPadding / 2),
              const Text("我們已將驗證碼發送至 "),
              Row(
                children: [
                  Text(
                    "abuanwar072@gmail.com",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("更改您的電子郵件？"),
                  )
                ],
              ),
              const SignUpVerificationOtpForm(),
              const SizedBox(height: defaultPadding),
              const Center(
                child: Text.rich(
                  TextSpan(
                    text: "重新發送驗證碼倒數 ",
                    children: [
                      TextSpan(
                        text: "1:36",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text("重新發送"),
                    ),
                  ),
                  const SizedBox(width: defaultPadding),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        customModalBottomSheet(
                          context,
                          isDismissible: false,
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(defaultPadding),
                              child: Column(
                                children: [
                                  Image.asset(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? "assets/Illustration/success.png"
                                        : "assets/Illustration/success_dark.png",
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                  ),
                                  const Spacer(),
                                  Text(
                                    "太棒了！",
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: defaultPadding / 2),
                                  const Text(
                                      "您的電子郵件已成功驗證。"),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          entryPointScreenRoute,
                                          ModalRoute.withName(
                                              signUpVerificationScreenRoute));
                                    },
                                    child: const Text("前往購物"),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text("確認"),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
