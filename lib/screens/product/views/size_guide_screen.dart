import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tklab_ec_v2/components/outlined_active_button.dart';

import '../../../constants.dart';
import 'components/centimeters_size_table.dart';
import 'components/inches_size_table.dart';

class SizeGuideScreen extends StatefulWidget {
  const SizeGuideScreen({super.key});

  @override
  State<SizeGuideScreen> createState() => _SizeGuideScreenState();
}

class _SizeGuideScreenState extends State<SizeGuideScreen> {
  bool _isShowCentimetersSize = false;

  void updateSizes() {
    setState(() {
      _isShowCentimetersSize = !_isShowCentimetersSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 2, vertical: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(),
                Text(
                  "尺寸指南",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/Share.svg",
                      colorFilter: ColorFilter.mode(Theme.of(context).textTheme.bodyLarge!.color!, BlendMode.srcIn)),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedActiveButton(
                          press: updateSizes,
                          text: "公分",
                          isActive: _isShowCentimetersSize,
                        ),
                      ),
                      const SizedBox(
                        width: defaultPadding,
                      ),
                      Expanded(
                        child: OutlinedActiveButton(
                          isActive: !_isShowCentimetersSize,
                          press: updateSizes,
                          text: "英吋",
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: defaultPadding * 1.5),
                    child: AnimatedSize(
                      duration: defaultDuration,
                      child: _isShowCentimetersSize
                          ? const CentimetersSizeTable()
                          : const InchesSizeTable(),
                    ),
                  ),
                  Text(
                    "測量指南",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: defaultPadding / 2),
                    child: Divider(),
                  ),
                  Text(
                    "胸圍",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "在胸部最豐滿的部位測量，確保繞過肩胛骨。",
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    "自然腰圍",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "在腰部最窄的部位測量，保持一根手指的空間在身體與測量帶之間。",
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
