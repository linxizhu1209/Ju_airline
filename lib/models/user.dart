class User {
  final int id;
  final String username;
  final String? password;
  final String email;

  User({
    required this.id,
    required this.username,
    this.password,
    required this.email,
});

  factory User.fromJson(Map<String, dynamic> json){
    return User(
        id: json['id'] ?? 0,
        username: json['username'] ?? '',
        password: json['password'],
        email: json['email'] ?? '',
    );
  }
}