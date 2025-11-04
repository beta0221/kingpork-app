import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tklab_ec_v2/components/cart_button.dart';
import 'package:tklab_ec_v2/components/custom_modal_bottom_sheet.dart';
import 'package:tklab_ec_v2/components/product/product_card.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/screens/product/views/product_info_screen.dart';
import 'package:tklab_ec_v2/screens/product/views/product_returns_screen.dart';
import 'package:tklab_ec_v2/screens/product/views/shipping_methods_screen.dart';
import 'package:tklab_ec_v2/route/screen_export.dart';

import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import '../../../components/review_card.dart';
import 'product_buy_now_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, this.isProductAvailable = true});

  final bool isProductAvailable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isProductAvailable
          ? CartButton(
              price: 1280,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductBuyNowScreen(),
                );
              },
            )
          :

          /// If profuct is not available then show [NotifyMeCard]
          NotifyMeCard(
              isNotify: false,
              onChanged: (value) {},
            ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                      colorFilter: ColorFilter.mode(Theme.of(context).textTheme.bodyLarge!.color!, BlendMode.srcIn)),
                ),
              ],
            ),
            const ProductImages(
              images: [
                "https://img.tklab.com.tw/uploads/product/202509/1562_fe6fc98f84144cb1854a3c76278febb8ea4a22e8_m.webp",
                "https://img.tklab.com.tw/uploads/product/202509/1562_5e8c2aa9a2288a65dfdc43c5df7f6d38b4dc99e2_m.webp",
                "https://img.tklab.com.tw/uploads/product/202509/1562_36a61623c23493ba954b16e5d49348c54ff3e2d5_m.webp"
              ],
            ),
            ProductInfo(
              brand: "TKLAB",
              title: "神經醯胺特潤保濕精華液",
              isAvailable: isProductAvailable,
              description:
                  "含有神經醯胺與玻尿酸的特潤保濕精華液,能深層滋潤肌膚,強化肌膚屏障,改善乾燥缺水問題。溫和不刺激,適合各種膚質使用,讓肌膚水潤飽滿有光澤...",
              rating: 4.8,
              numOfReviews: 235,
            ),
            ProductListTile(
              svgSrc: "assets/icons/Product.svg",
              title: "商品規格",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductInfoScreen(),
                );
              },
            ),
            ProductListTile(
              svgSrc: "assets/icons/Delivery.svg",
              title: "送貨與付款方式",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ShippingMethodsScreen(),
                );
              },
            ),
            ProductListTile(
              svgSrc: "assets/icons/Return.svg",
              title: "退貨須知",
              isShowBottomBorder: true,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductReturnsScreen(),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: ReviewCard(
                  rating: 4.3,
                  numOfReviews: 128,
                  numOfFiveStar: 80,
                  numOfFourStar: 30,
                  numOfThreeStar: 5,
                  numOfTwoStar: 4,
                  numOfOneStar: 1,
                ),
              ),
            ),
            ProductListTile(
              svgSrc: "assets/icons/Chat.svg",
              title: "評價",
              isShowBottomBorder: true,
              press: () {
                Navigator.pushNamed(context, productReviewsScreenRoute);
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "其他人也看了",
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final products = [
                      {"title": "玻尿酸保濕精華液", "price": 980.0, "discount": 880.0, "percent": 10, "img": "https://img.tklab.com.tw/uploads/product/202509/8214_172e393014105dfccdfa52a691412ee712ed3224_m.webp"},
                      {"title": "維他命C美白精華", "price": 1180.0, "discount": null, "percent": null, "img": "https://img.tklab.com.tw/uploads/product/202509/7866_813c23705579855d172ded3d08beebf526185138_m.webp"},
                      {"title": "膠原蛋白緊緻面霜", "price": 1480.0, "discount": 1280.0, "percent": 15, "img": "https://img.tklab.com.tw/uploads/product/202509/6800_1b2cebb4e091e00607b794207770c78836c5c022_m.webp"},
                      {"title": "煙醯胺淨白精華", "price": 1280.0, "discount": null, "percent": null, "img": "https://img.tklab.com.tw/uploads/product/202509/6802_68cb4c9cd968eb3548bc949fd86d0042ff0e09c7_m.webp"},
                      {"title": "胜肽抗皺精華液", "price": 1680.0, "discount": 1480.0, "percent": 12, "img": "https://img.tklab.com.tw/uploads/product/202509/5500_77f9e6a54c3834e22840f0680a9fa06b1a72e21d_m.webp"},
                    ];
                    final product = products[index];
                    return Padding(
                      padding: EdgeInsets.only(
                          left: defaultPadding,
                          right: index == 4 ? defaultPadding : 0),
                      child: ProductCard(
                        image: product["img"] as String,
                        title: product["title"] as String,
                        brandName: "TKLAB",
                        price: product["price"] as double,
                        priceAfetDiscount: product["discount"] as double?,
                        dicountpercent: product["percent"] as int?,
                        press: () {},
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            )
          ],
        ),
      ),
    );
  }
}
