import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';

class UserInfoForm extends StatelessWidget {
  const UserInfoForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          children: [
            TextFormField(
              initialValue: "Sepide Moqadasi",
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: defaultPadding * 0.75),
                  child: SvgPicture.asset(
                    "assets/icons/Profile.svg",
                    colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn),
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: TextFormField(
                initialValue: "theflutterway@gmail.com",
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: defaultPadding * 0.75),
                    child: SvgPicture.asset(
                      "assets/icons/Message.svg",
                      colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn),
                      height: 24,
                      width: 24,
                    ),
                  ),
                ),
              ),
            ),
            TextFormField(
              initialValue: "01/3/1999",
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: defaultPadding * 0.75),
                  child: SvgPicture.asset(
                    "assets/icons/Calender.svg",
                    colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn),
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: TextFormField(
                initialValue: "+1-202-555-0162",
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: defaultPadding),
                    child: SizedBox(
                      width: 72,
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/Call.svg",
                            height: 24,
                            width: 24,
                            colorFilter: ColorFilter.mode(
                                Theme.of(context).textTheme.bodyLarge!.color!,
                                BlendMode.srcIn),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding / 2),
                            child: Text("+1",
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                          const SizedBox(
                            height: 24,
                            child: VerticalDivider(
                              thickness: 1,
                              width: defaultPadding / 2,
                            ),
                          ),
                        ],
                      ),
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
