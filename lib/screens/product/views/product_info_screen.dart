import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:tklab_ec_v2/constants.dart';

class ProductInfoScreen extends StatelessWidget {
  const ProductInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            children: [
              const SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 40,
                    child: BackButton(),
                  ),
                  Text(
                    "商品詳情",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: defaultPadding),
                  child: Column(
                    children: [
                      HtmlWidget(
                        '''
                          <strong>商品</strong>

                          <p>保養品是用於清潔、滋潤、保護和改善皮膚狀態的產品，旨在維持或提升皮膚的光澤和健康。它們通常包含化妝水、乳液、面霜、精華液和面膜等種類，作用涵蓋保濕、營養補充、防曬及針對特定問題（如美白、控油、抗皺等）的護理。</p>
                          <strong>功用</strong>
                          <ul>
                            <li>保濕與滋潤</li>
                            <li>修護與調理</li>
                            <li>保護</li>
                            <li>特殊護理</li>
                          </ul>
                          <strong>款式說明</strong>
                          <p>透過提供水分和油分來維持皮膚油水平衡，如乳液、面霜、身體乳等。</p>
                          <p>精華液含有高濃度成分，能針對特定肌膚問題（如美白、抗皺、抗痘）進行密集修護。</p>
                          <p>包含針對眼部、頸部等部位的專用產品，或具有美白、控油等特殊功效的機能型產品。 </p>
                        ''',
                      ),
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
