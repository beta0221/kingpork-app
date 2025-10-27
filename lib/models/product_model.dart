// For demo only
import 'package:tklab_ec_v2/constants.dart';

class ProductModel {
  final String image, brandName, title;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;

  ProductModel({
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
  });
}

List<ProductModel> demoPopularProducts = [
  ProductModel(
    image: "https://img.tklab.com.tw/uploads/product/202509/5382_ffcc5cb7c3724d567d31bd452ecbe83e27af592b_s.webp",
    title: "羊珞素®生肌蜜168mL(重量版)",
    brandName: "TKLab",
    price: 540,
    priceAfetDiscount: 420,
    dicountpercent: 20,
  ),
  ProductModel(
    image: "https://img.tklab.com.tw/uploads/product/202509/5384_f8bfca50ed8ad963618f88a27736c1a7afa9d9fb_m.webp",
    title: "全能超值套裝組",
    brandName: "TKLab",
    price: 800,
  ),
  ProductModel(
    image: "https://img.tklab.com.tw/uploads/product/202509/5388_790617a1b212f0095ee92e644fda1c7494c3c2cc_m.webp",
    title: "羊珞素全能奇蹟霜(乾肌特潤)50g",
    brandName: "TKLab",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
  ),
  ProductModel(
    image: "https://img.tklab.com.tw/uploads/product/202509/9266_d5baefbc5105f86bdd5cdccd169c13e931d14df7_s.webp",
    title: "小秘密青春露酵母精華™50mL",
    brandName: "TKLab",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
  ),
  ProductModel(
    image: "https://img.tklab.com.tw/uploads/product/202505/3516_17c00779784acfd2184956aafb09e9e167d9a134_m.webp",
    title: "玻尿酸清爽保濕化妝水100mL",
    brandName: "TKLab",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
  ),
  ProductModel(
    image: "https://img.tklab.com.tw/uploads/product/202504/3516_e8840cec6e45c4768065245917e191e3ba8a5578_m.webp",
    title: "B5積雪草舒敏繃帶修復霜30g",
    brandName: "TKLab",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
  ),
];
List<ProductModel> demoFlashSaleProducts = [
  ProductModel(
    image: productDemoImg5,
    title: "FS - Nike Air Max 270 Really React",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
  ),
  ProductModel(
    image: productDemoImg6,
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
  ),
  ProductModel(
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 800,
    priceAfetDiscount: 680,
    dicountpercent: 15,
  ),
];
List<ProductModel> demoBestSellersProducts = [
  ProductModel(
    image: "https://i.imgur.com/tXyOMMG.png",
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
  ),
  ProductModel(
    image: "https://i.imgur.com/h2LqppX.png",
    title: "white satin corset top",
    brandName: "Lipsy london",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
  ),
  ProductModel(
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 800,
    priceAfetDiscount: 680,
    dicountpercent: 15,
  ),
];
List<ProductModel> kidsProducts = [
  ProductModel(
    image: "https://img.tklab.com.tw/uploads/product/202509/5382_ffcc5cb7c3724d567d31bd452ecbe83e27af592b_s.webp",
    title: "羊珞素®生肌蜜168mL(重量版)",
    brandName: "TKLab",
    price: 650.62,
    priceAfetDiscount: 590.36,
    dicountpercent: 24,
  ),
  ProductModel(
    image: "https://img.tklab.com.tw/uploads/product/202509/5384_f8bfca50ed8ad963618f88a27736c1a7afa9d9fb_m.webp",
    title: "全能超值套裝組",
    brandName: "TKLab",
    price: 650.62,
  ),
  ProductModel(
    image: "https://img.tklab.com.tw/uploads/product/202509/5388_790617a1b212f0095ee92e644fda1c7494c3c2cc_m.webp",
    title: "羊珞素全能奇蹟霜(乾肌特潤)50g",
    brandName: "TKLab",
    price: 400,
  ),
  ProductModel(
    image: "https://img.tklab.com.tw/uploads/product/202509/5388_f10725ced258d4d5599b9c739d037c325531f08c_m.webp",
    title: "小秘密青春露酵母精華™50mL",
    brandName: "TKLab",
    price: 400,
    priceAfetDiscount: 360,
    dicountpercent: 20,
  ),
  ProductModel(
    image: "https://img.tklab.com.tw/uploads/product/202505/3516_17c00779784acfd2184956aafb09e9e167d9a134_m.webp",
    title: "玻尿酸清爽保濕化妝水100mL",
    brandName: "TKLab",
    price: 654,
  ),
  ProductModel(
    image: "https://img.tklab.com.tw/uploads/product/202504/3516_e8840cec6e45c4768065245917e191e3ba8a5578_m.webp",
    title: "B5積雪草舒敏繃帶修復霜30g",
    brandName: "TKLab",
    price: 250,
  ),
];
