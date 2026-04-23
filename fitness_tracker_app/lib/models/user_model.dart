class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? password;
  final String? age;
  final String? mobileNumber;
  final String? height;
  final String? weight;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.password,
    this.age,
    this.mobileNumber,
    this.height,
    this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'password': password,
      'age': age,
      'mobileNumber': mobileNumber,
      'height': height,
      'weight': weight,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      password: map['password'],
      age: map['age'],
      mobileNumber: map['mobileNumber'],
      height: map['height'],
      weight: map['weight'],
    );
  }
}
