class UserE {
  final String id;
  final String email;
  final String displayName;
  final DateTime dateCreated;

  UserE({
    this.id  = '',
    required this.email,
    required this.displayName,
    required this.dateCreated,
  });

  // Create a User from JSON (e.g., from your backend)
  factory UserE.fromJson(Map<String, dynamic> json) {
    return UserE(
      id: json['id'].toString(),
      email: json['correo'],
      displayName: json['nombre_usuario'],
      dateCreated: DateTime.parse(json['fecha_creacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correo': email,
      'nombre_usuario': displayName,
      'fecha_creacion': dateCreated.toIso8601String(),
    };
  }
}
