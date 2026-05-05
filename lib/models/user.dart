class User {
  final int? id;
  final String name;
  final String email;
  final String? phone;

  User({this.id, required this.name, required this.email, this.phone});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        phone: map['phone']);
  }
}
