import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/route/screen_export.dart';

import 'components/address_card.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("地址列表"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/DotsV.svg",
              colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!, BlendMode.srcIn),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            vertical: defaultPadding, horizontal: defaultPadding),
        child: Column(
          children: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, addNewAddressesScreenRoute);
              },
              icon: SvgPicture.asset(
                "assets/icons/Location.svg",
                colorFilter: ColorFilter.mode(
                    Theme.of(context).iconTheme.color!, BlendMode.srcIn),
              ),
              label: Text(
                "新增地址",
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: AddressCard(
                title: "住家",
                address:
                    "台北市中山區XX路123號",
                pnNumber: "+886 923 536 999",
                isActive: true,
                press: () {},
              ),
            ),
            AddressCard(
              title: "公司",
              address: "台中市烏日區XX路666號",
              pnNumber: "+886 123 456 789",
              press: () {},
            ),
          ],
        ),
      ),
    );
  }
}
