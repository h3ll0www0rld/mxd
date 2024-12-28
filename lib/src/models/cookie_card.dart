// ignore_for_file: non_constant_identifier_names

class CookieCardModel {
  final String user_hash;
  final String name;
  bool isEnabled;

  CookieCardModel({
    required this.user_hash,
    required this.name,
    this.isEnabled = false,
  });

  factory CookieCardModel.fromJson(Map<String, dynamic> json) {
    return CookieCardModel(
      user_hash: json['cookie'],
      name: json['name'],
      isEnabled: json['isEnabled'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'cookie': user_hash,
      'name': name,
      'isEnabled': isEnabled,
    };
  }
}
