import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tklab_ec_v2/constants.dart';

import 'components/review_form.dart';
import 'components/review_product_card.dart';

class AddReviewScreen extends StatelessWidget {
  const AddReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("新增評價"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const ReviewProductInfoCard(
              image: productDemoImg1,
              title: "Sleeveless Ruffle",
              brand: "LIPSY LONDON",
            ),
            const SizedBox(height: defaultPadding),
            const Divider(),
            const SizedBox(height: defaultPadding / 2),
            const Text("您對此商品的整體評分"),
            const SizedBox(height: defaultPadding / 2),
            RatingBar.builder(
              initialRating: 0,
              itemSize: 28,
              itemPadding: const EdgeInsets.only(right: defaultPadding / 4),
              unratedColor: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color!
                  .withValues(alpha: 0.08),
              glow: false,
              allowHalfRating: true,
              onRatingUpdate: (value) {
                // Update your rating
              },
              itemBuilder: (context, index) =>
                  SvgPicture.asset("assets/icons/Star_filled.svg"),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: defaultPadding),
              child: Divider(),
            ),
            const ReviewForm()
          ],
        ),
      ),
    );
  }
}
