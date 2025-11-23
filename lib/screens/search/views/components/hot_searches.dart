import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/constants.dart';

class HotSearches extends StatelessWidget {
  const HotSearches({super.key, this.onTapKeyword});

  final void Function(String keyword)? onTapKeyword;

  @override
  Widget build(BuildContext context) {
    const List<String> hotKeywords = [
      "羊珞素",
      "膠原蛋白",
      "全能",
      "夜酵素",
      "輕仙飲",
      "魚油",
      "雪藻",
      "小銀管",
      "粉餅",
      "雙頭唇膏",
      "潔顏霜",
      "青春露",
      "保濕",
      "VEP",
      "A醇",
      "角鯊",
      "淡斑",
      "杏仁酸",
      "淨痘",
      "控油",
      "防曬",
      "男仕",
      "白白",
      "酒神飲",
      "益生菌",
      "葉黃素",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "熱門搜尋",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: defaultPadding),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: List.generate(
              hotKeywords.length,
              (index) => _HotSearchTag(
                keyword: hotKeywords[index],
                showFireIcon: index == 0,
                onTap: () => onTapKeyword?.call(hotKeywords[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotSearchTag extends StatelessWidget {
  const _HotSearchTag({
    required this.keyword,
    this.showFireIcon = false,
    this.onTap,
  });

  final String keyword;
  final bool showFireIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showFireIcon) ...[
              const Text("🔥", style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
            ],
            Text(
              keyword,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
