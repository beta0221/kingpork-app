/// Address model
class Address {
  final int id;
  final String name;
  final String recipient;
  final String phone;
  final String city;
  final String district;
  final String address;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.recipient,
    required this.phone,
    required this.city,
    required this.district,
    required this.address,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int,
      name: json['name'] as String,
      recipient: json['recipient'] as String,
      phone: json['phone'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      address: json['address'] as String,
      isDefault: json['is_default'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'recipient': recipient,
      'phone': phone,
      'city': city,
      'district': district,
      'address': address,
      'is_default': isDefault,
    };
  }

  /// Get full address string
  String get fullAddress => '$city$district$address';
}
