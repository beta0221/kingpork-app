import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/components/Banner/L/banner_l_style_1.dart';
import 'package:tklab_ec_v2/components/Banner/S/banner_s_style_1.dart';
import 'package:tklab_ec_v2/components/Banner/S/banner_s_style_4.dart';
import 'package:tklab_ec_v2/components/shopping_bag.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/screens/home/views/components/best_sellers.dart';
import 'package:tklab_ec_v2/screens/home/views/components/flash_sale.dart';
import 'package:tklab_ec_v2/screens/home/views/components/most_popular.dart';
import 'package:tklab_ec_v2/screens/home/views/components/popular_products.dart';

class OnSaleScreen extends StatelessWidget {
  const OnSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // const SliverAppBar(
            //   floating: true,
            //   title: Text("特價中"),
            //   actions: [
            //     ShoppingBag(
            //       numOfItem: 3,
            //     ),
            //   ],
            // ),
            SliverToBoxAdapter(
              child: BannerLStyle1(
                image: "https://i.ytimg.com/vi/1AUhrQwoQtU/maxresdefault.jpg",
                title: "夏季\n特賣",
                subtitle: "特別優惠",
                discountPercent: 50,
                press: () {},
              ),
            ),
            const SliverToBoxAdapter(
              child: BestSellers(),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(top: defaultPadding),
              sliver: SliverToBoxAdapter(
                child: FlashSale(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    BannerSStyle1(
                      image: "https://img.tklab.com.tw/uploads/category/September2025/b72c330d77ce80f31e82471705417631259d0e4c.webp",
                      title: "新品\n上市",
                      subtitle: "特別優惠",
                      discountParcent: 50,
                      press: () {},
                    ),
                    const SizedBox(height: defaultPadding / 4),
                    BannerSStyle4(
                      image: "https://img.tklab.com.tw/uploads/category/March2025/d112cfc1ffd19934dc5207006514571ffcf51d5e.webp",
                      title: "夏季\n特賣",
                      subtitle: "特別優惠",
                      bottomText: "最高 8 折優惠",
                      press: () {},
                    ),
                    const SizedBox(height: defaultPadding / 4),
                    BannerSStyle4(
                      image: "https://img.tklab.com.tw/uploads/category/September2025/892615558ecc45d9a3741eb1af6067f15c875cd6.webp",
                      title: "黑色\n星期五",
                      subtitle: "5 折優惠",
                      bottomText: "系列".toUpperCase(),
                      press: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: PopularProducts(),
            ),
            const SliverToBoxAdapter(
              child: MostPopular(),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: defaultPadding),
              sliver: SliverToBoxAdapter(
                child: BannerLStyle1(
                  image: "https://i.ytimg.com/vi/Nw9cOBCg2rk/maxresdefault.jpg?sqp=-oaymwEmCIAKENAF8quKqQMa8AEB-AH-CYAC0AWKAgwIABABGGUgTShBMA8=&rs=AOn4CLBnuMTGHn5PoYLlnJjWQwndlS73FQ",
                  title: "夏季\n特賣",
                  subtitle: "特別優惠",
                  discountPercent: 50,
                  press: () {},
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: BestSellers(),
            ),
          ],
        ),
      ),
    );
  }
}
