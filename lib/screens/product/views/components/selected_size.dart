import 'package:flutter/material.dart';

import '../../../../constants.dart';

class SelectedSize extends StatelessWidget {
  const SelectedSize({
    super.key,
    required this.sizes,
    required this.selectedIndex,
    required this.press,
  });

  final List<String> sizes;
  final int selectedIndex;
  final ValueChanged<int> press;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: defaultPadding),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "選擇規格/容量",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Wrap(
            spacing: defaultPadding / 2,
            runSpacing: defaultPadding / 2,
            children: List.generate(
              sizes.length,
              (index) => SizeButton(
                text: sizes[index],
                isActive: selectedIndex == index,
                press: () => press(index),
              ),
            ),
          ),
        ),
        const SizedBox(height: defaultPadding / 2),
      ],
    );
  }
}

class SizeButton extends StatelessWidget {
  const SizeButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.press,
  });

  final String text;
  final bool isActive;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: press,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        side: isActive
            ? const BorderSide(color: primaryColor, width: 1.5)
            : BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: isActive
              ? primaryColor
              : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
        ),
      ),
    );
  }
}
