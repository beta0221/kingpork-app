import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';
import 'rating_sort_dropdown_button.dart';

class SortUserReview extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          Expanded(
            child: Text(
              "使用者評價",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          SvgPicture.asset(
            "assets/icons/Sort.svg",
            colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color!, BlendMode.srcIn),
          ),
          const SizedBox(width: defaultPadding / 2),
          RatingSortDropdownButton(
            items: const ['最有幫助', '最新'],
            value: "最有幫助",
            onChanged: (value) {
              // Set the dropdown value
            },
          )
        ],
      ),
    );
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
