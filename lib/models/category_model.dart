class CategoryModel {
  final String title;
  final String? image, svgSrc;
  final List<CategoryModel>? subCategories;

  CategoryModel({
    required this.title,
    this.image,
    this.svgSrc,
    this.subCategories,
  });
}

final List<CategoryModel> demoCategoriesWithImage = [
  CategoryModel(title: "Woman’s", image: "https://i.imgur.com/5M89G2P.png"),
  CategoryModel(title: "Man’s", image: "https://i.imgur.com/UM3GdWg.png"),
  CategoryModel(title: "Kid’s", image: "https://i.imgur.com/Lp0D6k5.png"),
  CategoryModel(title: "Accessories", image: "https://i.imgur.com/3mSE5sN.png"),
];

final List<CategoryModel> demoCategories = [
  CategoryModel(
    title: "優惠",
    svgSrc: "assets/icons/Sale.svg",
    subCategories: [
      CategoryModel(title: "年度囤貨組"),
      CategoryModel(title: "鍾明軒推薦：TKLAB重量版羊珞素168mL"),
      CategoryModel(title: "美容大王大S代言：TKLAB羊珞素"),
      CategoryModel(title: "羊珞素全能系列超值套裝組"),
      CategoryModel(title: "國際巨星小S代言：TKLAB膠原蛋白飲"),
      CategoryModel(title: "王子代言：TKLAB特濃夜酵素Plus"),
    ],
  ),
  CategoryModel(
    title: "保養品",
    svgSrc: "assets/icons/Man&Woman.svg",
    subCategories: [
      CategoryModel(title: "羊珞素"),
      CategoryModel(title: "青春露"),
      CategoryModel(title: "玻尿酸保濕"),
      CategoryModel(title: "積雪草舒敏"),
      CategoryModel(title: "彈潤緊緻"),
      CategoryModel(title: "角鯊"),
    ],
  ),
  CategoryModel(
    title: "保健",
    svgSrc: "assets/icons/Child.svg",
    subCategories: [
      CategoryModel(title: "孕哺婦保健食品"),
      CategoryModel(title: "兒童保健食品"),
      CategoryModel(title: "銀髮族保健食品"),
      CategoryModel(title: "男性保健食品"),
    ],
  ),
  CategoryModel(
    title: "彩妝",
    svgSrc: "assets/icons/Accessories.svg",
    subCategories: [
      CategoryModel(title: "彩妝全部商品")
    ],
  ),
];
