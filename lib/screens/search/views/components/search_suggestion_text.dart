import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tklab_ec_v2/constants.dart';

class SearchSuggestionText extends StatelessWidget {
  const SearchSuggestionText({
    super.key,
    required this.text,
    this.press,
    this.onTapClose,
    this.isRecentSearch = false,
  });

  final String text;
  final VoidCallback? press, onTapClose;
  final bool isRecentSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: press,
          minLeadingWidth: 24,
          horizontalTitleGap: defaultPadding / 2,
          leading: isRecentSearch
              ? SvgPicture.asset(
                  "assets/icons/Clock.svg",
                  height: 24,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).iconTheme.color!.withValues(alpha: 0.3),
                      BlendMode.srcIn),
                )
              : null,
          title: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.normal),
          ),
          trailing: IconButton(
            iconSize: 16,
            icon: SvgPicture.asset(
              "assets/icons/Close.svg",
              colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!.withValues(alpha: 0.5),
                  BlendMode.srcIn),
              height: 16,
            ),
            onPressed: onTapClose,
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
