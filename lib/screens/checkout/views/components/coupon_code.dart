import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';

class CouponCode extends StatefulWidget {
  const CouponCode({
    super.key,
  });

  @override
  State<CouponCode> createState() => _CouponCodeState();
}

class _CouponCodeState extends State<CouponCode> {
  bool _isShoeApplyBtn = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "優惠券代碼",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: defaultPadding),
        Form(
          child: TextFormField(
            onSaved: (code) {},
            onChanged: (value) {
              if (value.length > 2) {
                setState(() {
                  _isShoeApplyBtn = true;
                });
              } else if (_isShoeApplyBtn == true) {
                setState(() {
                  _isShoeApplyBtn = false;
                });
              }
            },
            decoration: InputDecoration(
              hintText: "請輸入優惠券代碼",
              prefixIcon: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Coupon.svg",
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).inputDecorationTheme.hintStyle!.color!,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isShoeApplyBtn) const SizedBox(height: defaultPadding),
        Visibility(
          visible: _isShoeApplyBtn,
          child: OutlinedButton(
            onPressed: () {},
            child: Text(
              "套用優惠券",
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color!),
            ),
          ),
        ),
      ],
    );
  }
}
