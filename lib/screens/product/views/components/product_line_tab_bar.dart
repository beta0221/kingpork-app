import 'package:flutter/material.dart';
import '/models/product_line_model.dart';
import '/constants.dart';

/// 可重用的水平滚动产品线标签栏组件
class ProductLineTabBar extends StatelessWidget {
  /// 产品线列表
  final List<ProductLine> productLines;

  /// 当前选中的索引
  final int selectedIndex;

  /// 标签被点击时的回调
  final Function(int) onTabSelected;

  /// 滚动控制器
  final ScrollController scrollController;

  const ProductLineTabBar({
    super.key,
    required this.productLines,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: blackColor10,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: productLines.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final productLine = productLines[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 产品线名称
                  Text(
                    productLine.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? (Theme.of(context).brightness == Brightness.light
                              ? blackColor
                              : whiteColor)
                          : blackColor40,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 选中指示器
                  Container(
                    height: 2,
                    width: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? errorColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
