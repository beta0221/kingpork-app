import 'package:flutter/material.dart';

import 'search_suggestion_text.dart';

class SearchSuggestions extends StatelessWidget {
  const SearchSuggestions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const List<String> demoSuggestion = [
      "膠原蛋白飲",
      "保濕精華液",
      "解酒神飲"
    ];
    return Column(
      children: List.generate(
        demoSuggestion.length,
        (index) => SearchSuggestionText(
          text: demoSuggestion[index],
          press: () {},
        ),
      ),
    );
  }
}
