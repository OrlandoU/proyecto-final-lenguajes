class Goal {
  final String id;
  final int goalType;
  final int amountType;
  final String userId;
  final String title;
  final String description;
  final String startDate;

  Goal({
    required this.id,
    required this.goalType,
    required this.amountType,
    required this.userId,
    required this.title,
    required this.description,
    required this.startDate,
  });

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'].toString(),
        goalType: json['tipo_objetivo'],
        amountType: json['tipo_monto'],
        userId: json['idUsuario'].toString(),
        title: json['titulo'],
        description: json['descripcion'],
        startDate: json['fecha_inicial'],
      );

  Map<String, dynamic> toJson() {
    return {
      'tipo_objetivo': goalType,
      'tipo_monto': amountType,
      'idUsuario': userId,
      'titulo': title,
      'descripcion': description,
      'fecha_inicial': startDate,
    };
  }
}
