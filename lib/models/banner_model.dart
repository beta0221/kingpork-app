/// Banner model for landing page
class BannerModel {
  final int id;
  final String image;
  final String link;
  final String alt;
  final String imgUrl;

  BannerModel({
    required this.id,
    required this.image,
    required this.link,
    required this.alt,
    required this.imgUrl,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      image: json['image'] as String,
      link: json['link'] as String,
      alt: json['alt'] as String,
      imgUrl: json['imgUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'link': link,
      'alt': alt,
      'imgUrl': imgUrl,
    };
  }
}
