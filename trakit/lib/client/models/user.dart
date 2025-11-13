class User {
  final String id;
  final String email;
  final String username;
  final String password;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'].toString(),
        email: json['correo'],
        username: json['nombre_usuario'],
        password: json['password'],
      );

  Map<String, dynamic> toJson() {
    return {
      'correo': email,
      'nombre_usuario': username,
      'password': password,
    };
  }
}
