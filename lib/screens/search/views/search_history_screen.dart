import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/constants.dart';

import 'components/search_suggestion_text.dart';

class SearchHistoryScreen extends StatelessWidget {
  const SearchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> demoRecentSearch = [
      "膠原蛋白飲",
      "保濕精華液",
      "解酒神飲"
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("搜尋歷史"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("清除"),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "今日  2022-03-29",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            ...List.generate(
              demoRecentSearch.length,
              (index) => SearchSuggestionText(
                text: demoRecentSearch[index],
                press: () {},
                onTapClose: () {},
              ),
            ),
            const SizedBox(height: defaultPadding * 1.5),
            Text(
              "昨日  2021-03-28",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            ...List.generate(
              demoRecentSearch.length,
              (index) => SearchSuggestionText(
                text: demoRecentSearch[index],
                press: () {},
                onTapClose: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
