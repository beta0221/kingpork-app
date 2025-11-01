import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/route/screen_export.dart';

import 'components/new_pass_form.dart';

class SetNewPasswordScreen extends StatelessWidget {
  const SetNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> key = GlobalKey<FormState>();
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
              const Text(
                  "您的新密碼必須與先前使用的密碼不同。"),
              const SizedBox(
                height: defaultPadding * 2,
              ),
              NewPassForm(formKey: key),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (key.currentState!.validate()) {
                    Navigator.pushNamedAndRemoveUntil(context,
                        doneResetPasswordScreenRoute, (route) => false);
                  }
                },
                child: const Text("更改密碼"),
              ),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}
