import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:tklab_ec_v2/constants.dart';

import 'components/use_current_location_card.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("新增地址"),
      ),
      body: SafeArea(
        child: Form(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                TextFormField(
                  onSaved: (newValue) {},
                  validator:
                      RequiredValidator(errorText: "此欄位為必填")
                          .call,
                  decoration: const InputDecoration(
                    hintText: "輸入地址標題",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: defaultPadding * 1.5),
                  child: UseCurrentLocationCard(press: () {}),
                ),
                TextFormField(
                  onSaved: (newValue) {},
                  validator:
                      RequiredValidator(errorText: "此欄位為必填")
                          .call,
                  decoration: InputDecoration(
                    hintText: "國家/地區",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: defaultPadding * 0.74),
                      child: SvgPicture.asset(
                        "assets/icons/Address.svg",
                        height: 24,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                            Theme.of(context)
                                .inputDecorationTheme
                                .hintStyle!
                                .color!,
                            BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  child: TextFormField(
                    onSaved: (newValue) {},
                    validator:
                        RequiredValidator(errorText: "此欄位為必填")
                            .call,
                    decoration: InputDecoration(
                      hintText: "全名",
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: defaultPadding * 0.74),
                        child: SvgPicture.asset(
                          "assets/icons/Profile.svg",
                          height: 24,
                          width: 24,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context)
                                  .inputDecorationTheme
                                  .hintStyle!
                                  .color!,
                              BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  onSaved: (newValue) {},
                  validator:
                      RequiredValidator(errorText: "此欄位為必填")
                          .call,
                  decoration: const InputDecoration(
                    hintText: "地址第一行",
                  ),
                ),
                const SizedBox(height: defaultPadding),
                TextFormField(
                  onSaved: (newValue) {},
                  decoration: const InputDecoration(
                    hintText: "地址第二行",
                  ),
                ),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: defaultPadding),
                  title: const Text("郵政信箱"),
                  trailing: CupertinoSwitch(
                    onChanged: (value) {},
                    value: false,
                    activeTrackColor: primaryColor,
                  ),
                ),
                TextFormField(
                  onSaved: (newValue) {},
                  decoration: const InputDecoration(
                    hintText: "城市",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  child: TextFormField(
                    onSaved: (newValue) {},
                    decoration: const InputDecoration(
                      hintText: "州/省",
                    ),
                  ),
                ),
                TextFormField(
                  onSaved: (newValue) {},
                  decoration: const InputDecoration(
                    hintText: "郵遞區號",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "電話號碼",
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
                                    Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!,
                                    BlendMode.srcIn),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: defaultPadding / 2),
                                child: Text("+1",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
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
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("設為預設地址"),
                  trailing: CupertinoSwitch(
                    onChanged: (value) {},
                    value: true,
                    activeTrackColor: primaryColor,
                  ),
                ),
                const SizedBox(height: defaultPadding * 1.5),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("儲存地址"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
