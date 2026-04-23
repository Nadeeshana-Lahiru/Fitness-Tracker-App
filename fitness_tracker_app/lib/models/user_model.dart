class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? password;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      password: map['password'],
    );
  }
}
