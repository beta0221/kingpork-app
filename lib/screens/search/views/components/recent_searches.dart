import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/route/screen_export.dart';

import '../../../../constants.dart';
import 'search_suggestion_text.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const List<String> demoRecentSearch = [
      "White Shirt",
      "Blue short",
      "Red shirt",
      "Gray Dress",
      "Yellow Top &  short"
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "最近搜尋",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, searchHistoryScreenRoute);
                },
                child: const Text("查看全部"),
              ),
            ],
          ),
        ),
        ...List.generate(
          demoRecentSearch.length,
          (index) => SearchSuggestionText(
            text: demoRecentSearch[index],
            isRecentSearch: true,
            press: () {},
            onTapClose: () {},
          ),
        ),
      ],
    );
  }
}
