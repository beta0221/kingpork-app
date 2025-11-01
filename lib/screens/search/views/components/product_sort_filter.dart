import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../components/list_tile/checkbox_underline_list_tile.dart';

// For Demo
class SizeModel {
  final String title;
  final int? numOfItems;

  SizeModel({required this.title, this.numOfItems});
}
// End for demo

class ProductSortFilter extends StatefulWidget {
  const ProductSortFilter({super.key});

  @override
  State<ProductSortFilter> createState() => _ProductSortFilterState();
}

class _ProductSortFilterState extends State<ProductSortFilter> {
  final List<SizeModel> demoSortFilters = [
    SizeModel(title: "價格 [低至高]"),
    SizeModel(title: "價格 [高至低]"),
    SizeModel(title: "新品上市"),
    SizeModel(title: "最高評價"),
    SizeModel(title: "A-Z"),
    SizeModel(title: "Z-A"),
  ];
  List<SizeModel> sortFilters = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                child: Column(
                  children: List.generate(
                    demoSortFilters.length,
                    (index) => CheckboxUnderlineListTile(
                      onChanged: (value) {
                        if (value! &&
                            !sortFilters.contains(demoSortFilters[index])) {
                          sortFilters.clear();
                          setState(() {
                            sortFilters.add(demoSortFilters[index]);
                          });
                        } else if (!value &&
                            sortFilters.contains(demoSortFilters[index])) {
                          setState(() {
                            sortFilters.remove(demoSortFilters[index]);
                          });
                        }
                      },
                      title: demoSortFilters[index].title,
                      value: sortFilters.contains(demoSortFilters[index]),
                      numOfItems: demoSortFilters[index].numOfItems,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("完成"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
