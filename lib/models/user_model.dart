class UserModel {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String fullName;
  final String? profileImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    this.profileImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  // Add getter for compatibility with old code
  String get name => fullName;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
      'profileImagePath': profileImagePath,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toInt(),
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      fullName: map['fullName'] ?? '',
      profileImagePath: map['profileImagePath'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? fullName,
    String? profileImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}