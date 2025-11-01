import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/components/review_card.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/screens/product/views/components/product_list_tile.dart';
import 'package:tklab_ec_v2/route/screen_export.dart';

import 'components/sort_user_review.dart';
import 'components/user_review_card.dart';

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text("評價"),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: defaultPadding),
            sliver: SliverToBoxAdapter(
              child: ReviewCard(
                rating: 4.3,
                numOfReviews: 120,
                numOfFiveStar: 90,
                numOfFourStar: 20,
                numOfThreeStar: 4,
                numOfTwoStar: 0,
                numOfOneStar: 6,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            sliver: ProductListTile(
              title: "新增評價",
              svgSrc: "assets/icons/Chat-add.svg",
              isShowBottomBorder: true,
              press: () {
                Navigator.pushNamed(context, addReviewsScreenRoute);
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            sliver: SliverPersistentHeader(
              delegate: SortUserReview(),
              pinned: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(top: defaultPadding),
                  child: UserReviewCard(
                    rating: 4.2,
                    name: "Arman Rokni",
                    userImage:
                        index.isEven ? null : "https://i.imgur.com/4h34UKX.png",
                    time: "36s",
                    review:
                        "保養品是用於清潔、滋潤、保護和改善皮膚狀態的產品，旨在維持或提升皮膚的光澤和健康。它們通常包含化妝水、乳液、面霜、精華液和面膜等種類，作用涵蓋保濕、營養補充、防曬及針對特定問題（如美白、控油、抗皺等）的護理。",
                  ),
                ),
                childCount: 7,
              ),
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding * 1.5)),
        ],
      ),
    );
  }
}
