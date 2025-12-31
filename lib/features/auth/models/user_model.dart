// lib/features/auth/models/user_model.dart

/// User model representing authenticated user data
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? token;
  final String? refreshToken;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.token,
    this.refreshToken,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      token: json['token'],
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
      'refreshToken': refreshToken,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? token,
    String? refreshToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
