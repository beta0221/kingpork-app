import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/route/screen_export.dart';

import 'components/otp_form.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

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
                    "+99******1233",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("更改電話號碼？"),
                  )
                ],
              ),
              const OtpForm(),
              const SizedBox(height: defaultPadding),
              const Center(
                child: Text.rich(
                  TextSpan(
                    text: "重新發送驗證碼於 ",
                    children: [
                      TextSpan(
                        text: "1:36",
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: " 後",
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
                        Navigator.pushNamed(context, newPasswordScreenRoute);
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
