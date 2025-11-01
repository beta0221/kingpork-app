import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tklab_ec_v2/components/network_image_with_loader.dart';

import '../../../../constants.dart';

class UserReviewCard extends StatelessWidget {
  const UserReviewCard({
    super.key,
    required this.name,
    required this.review,
    required this.time,
    this.userImage,
    required this.rating,
  });

  final String name, review, time;
  final String? userImage;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .textTheme
            .bodyLarge!
            .color!
            .withValues(alpha: 0.05),
        borderRadius:
            const BorderRadius.all(Radius.circular(defaultBorderRadious)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withValues(alpha: 0.1),
                child: userImage == null
                    ? SvgPicture.asset(
                        "assets/icons/Profile.svg",
                        height: 16,
                        colorFilter: ColorFilter.mode(
                            Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!
                                .withValues(alpha: 0.3),
                            BlendMode.srcIn),
                      )
                    : NetworkImageWithLoader(userImage!),
              ),
              const SizedBox(width: defaultPadding / 2),
              Text(
                "Arman Rokni",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: defaultPadding / 4),
              Text(
                "36s ago",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              RatingBar.builder(
                initialRating: 4,
                itemSize: 16,
                itemPadding: const EdgeInsets.only(right: defaultPadding / 4),
                unratedColor: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withValues(alpha: 0.08),
                glow: false,
                allowHalfRating: true,
                ignoreGestures: true,
                onRatingUpdate: (value) {},
                itemBuilder: (context, index) =>
                    SvgPicture.asset("assets/icons/Star_filled.svg"),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          const Text(
            "“保養品是用於清潔、滋潤、保護和改善皮膚狀態的產品，旨在維持或提升皮膚的光澤和健康。它們通常包含化妝水、乳液、面霜、精華液和面膜等種類，作用涵蓋保濕、營養補充、防曬及針對特定問題（如美白、控油、抗皺等）的護理。”",
          )
        ],
      ),
    );
  }
}
