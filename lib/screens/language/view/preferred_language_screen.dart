import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/route/route_constants.dart';
import 'package:tklab_ec_v2/theme/input_decoration_theme.dart';

import 'components/language_card.dart';

class PreferredLanguageScreen extends StatelessWidget {
  const PreferredLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                "選擇您的偏好語言",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: defaultPadding / 2),
              const Text("您將在整個應用程式中使用相同的語言。"),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                child: Form(
                  child: TextFormField(
                    onSaved: (language) {},
                    validator: (value) {
                      return null;
                    }, // validate your textfield
                    decoration: InputDecoration(
                      hintText: "搜尋您的語言",
                      filled: false,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(defaultPadding / 2),
                        child: SvgPicture.asset(
                          "assets/icons/Search.svg",
                          height: 24,
                          width: 24,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!
                                .withValues(alpha: 0.25),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      border: secodaryOutlineInputBorder(context),
                      enabledBorder: secodaryOutlineInputBorder(context),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: ListView.separated(
                  itemCount: 5,
                  itemBuilder: (context, index) => LanguageCard(
                    language: demoLanguage[index],
                    flag: demoFlags[index],
                    isActive: index == 0,
                    press: () {},
                  ),
                  separatorBuilder: (context, index) => const SizedBox(
                    height: defaultPadding / 2,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, logInScreenRoute);
                },
                child: const Text("下一步"),
              ),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}

// Only for preview
const List<String> demoFlags = [
  "assets/flags/England.svg",
  "assets/flags/france.svg",
  "assets/flags/German.svg",
  "assets/flags/India.svg",
  "assets/flags/Italy.svg",
  "assets/flags/japaness.svg",
];
const List<String> demoLanguage = [
  "英文",
  "法文",
  "德文",
  "印地文",
  "義大利文",
  "日文"
];
