import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tklab_ec_v2/components/shopping_bag.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/screens/search/views/components/search_form.dart';

class SubDiscoverScreen extends StatelessWidget {
  const SubDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> demoManWomanItems = [
      "所有服飾",
      "新品上架",
      "外套與夾克",
      "洋裝",
      "連帽衫與運動衫",
      "牛仔褲"
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("男裝與女裝"),
        actions: const [
          Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: ShoppingBag(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: defaultPadding),
                child: SearchForm(),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: demoManWomanItems.length,
                  itemBuilder: (context, index) => Column(
                    children: [
                      ListTile(
                        onLongPress: () {},
                        title: Text(
                          demoManWomanItems[index],
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontWeight: FontWeight.normal),
                        ),
                        trailing: SvgPicture.asset(
                          "assets/icons/miniRight.svg",
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).iconTheme.color!.withValues(alpha: 0.3),
                            BlendMode.srcIn,
                          ),
                          
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
