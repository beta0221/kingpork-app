import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/components/custom_modal_bottom_sheet.dart';
import 'package:tklab_ec_v2/components/list_tile/divider_list_tile.dart';
import 'package:tklab_ec_v2/components/outlined_active_button.dart';
import 'package:tklab_ec_v2/screens/search/views/components/brand_filter.dart';
import 'package:tklab_ec_v2/screens/search/views/components/color_filter.dart';
import 'package:tklab_ec_v2/screens/search/views/components/price_filter.dart';
import 'package:tklab_ec_v2/screens/search/views/components/product_sort_filter.dart';

import '../../../../constants.dart';
import 'size_fiter.dart';

class SearchFilter extends StatefulWidget {
  const SearchFilter({
    super.key,
  });

  @override
  State<SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  bool _isShowSort = false;
  bool _isShowAvailableProducOnly = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Row(
                children: [
                  const SizedBox(
                    width: 40,
                    child: BackButton(),
                  ),
                  const SizedBox(width: 32),
                  const Spacer(),
                  Text(
                    "篩選",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text("清除"),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedActiveButton(
                      press: () {
                        setState(() {
                          _isShowSort = false;
                        });
                      },
                      text: "篩選",
                      isActive: !_isShowSort,
                    ),
                  ),
                  const SizedBox(width: defaultPadding),
                  Expanded(
                    child: OutlinedActiveButton(
                      press: () {
                        setState(() {
                          _isShowSort = true;
                        });
                      },
                      text: "排序",
                      isActive: _isShowSort,
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: defaultPadding),
            _isShowSort
                ? const Expanded(child: ProductSortFilter())
                : Expanded(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.symmetric(vertical: defaultPadding),
                      child: Column(
                        children: [
                          DividerListTile(
                            title: const Text("顏色"),
                            press: () {
                              customModalBottomSheet(
                                context,
                                height:
                                    MediaQuery.of(context).size.height * 0.82,
                                child: const ProductColorFilter(),
                              );
                            },
                          ),
                          DividerListTile(
                            title: const Text("尺寸"),
                            press: () {
                              customModalBottomSheet(
                                context,
                                height:
                                    MediaQuery.of(context).size.height * 0.82,
                                child: const SizeFilter(),
                              );
                            },
                          ),
                          DividerListTile(
                            title: const Text("品牌"),
                            press: () {
                              customModalBottomSheet(
                                context,
                                height:
                                    MediaQuery.of(context).size.height * 0.82,
                                child: const BrandFilter(),
                              );
                            },
                          ),
                          DividerListTile(
                            title: const Text("價格"),
                            press: () {
                              customModalBottomSheet(
                                context,
                                height:
                                    MediaQuery.of(context).size.height * 0.82,
                                child: const PriceFilter(),
                              );
                            },
                          ),
                          CheckboxListTile(
                            activeColor: primaryColor,
                            onChanged: (value) {
                              setState(() {
                                _isShowAvailableProducOnly = value!;
                              });
                            },
                            value: _isShowAvailableProducOnly,
                            title: const Text("現貨供應"),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding / 2),
                          )
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
