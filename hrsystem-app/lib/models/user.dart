class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? photoUrl;
  final String? department;
  final String? position;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.department,
    this.position,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      photoUrl: json['photo_url'] as String?,
      department: json['department'] as String?,
      position: json['position'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'photo_url': photoUrl,
      'department': department,
      'position': position,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? photoUrl,
    String? department,
    String? position,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      department: department ?? this.department,
      position: position ?? this.position,
    );
  }
}
