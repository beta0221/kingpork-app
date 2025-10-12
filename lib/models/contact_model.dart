/// Contact form request model
class ContactRequest {
  final String name;
  final String email;
  final String phone;
  final String message;

  ContactRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'message': message,
    };
  }
}

/// Contact form response model
class ContactResponse {
  final String message;

  ContactResponse({
    required this.message,
  });

  factory ContactResponse.fromJson(Map<String, dynamic> json) {
    return ContactResponse(
      message: json['message'] as String,
    );
  }
}
