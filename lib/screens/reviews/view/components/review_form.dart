import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:tklab_ec_v2/route/route_constants.dart';

import '../../../../constants.dart';

class ReviewForm extends StatelessWidget {
  const ReviewForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "為您的評價設定標題",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            onSaved: (reviewTitle) {},
            validator: (value) {
              return null;
            },
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: "評價摘要",
            ),
          ),
          const SizedBox(height: defaultPadding / 4),
          Text(
            "最多100個字元",
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: defaultPadding * 1.5),
          Text(
            "您喜歡或不喜歡什麼？",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            onSaved: (review) {},
            validator:
                RequiredValidator(errorText: "此欄位為必填").call,
            maxLines: 5,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: "購物者應該事先知道什麼？",
            ),
          ),
          const SizedBox(height: defaultPadding / 4),
          Text(
            "最多3000個字元",
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: defaultPadding),
            child: Divider(),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  "您會推薦此商品嗎？",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(width: defaultPadding),
              CupertinoSwitch(
                onChanged: (value) {},
                activeTrackColor: primaryMaterialColor.shade900,
                value: true,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: defaultPadding * 1.5, bottom: defaultPadding),
            child: ElevatedButton(
              onPressed: () {
                // Validate the form field
                if (formKey.currentState!.validate()) {
                  Navigator.popAndPushNamed(context, productReviewsScreenRoute);
                }
              },
              child: const Text("提交評價"),
            ),
          )
        ],
      ),
    );
  }
}
