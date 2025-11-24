class Week {
  final String id;
  final double realAmount;
  final double plannedAmount;
  final String goalId;
  final bool completedStatus;
  final int number;

  Week({
    this.id = '',
    required this.realAmount,
    required this.plannedAmount,
    required this.goalId,
    required this.completedStatus,
    required this.number
  });

  factory Week.fromJson(Map<String, dynamic> json) => Week(
        id: json['id'].toString(),
        realAmount: json['monto_real'],
        plannedAmount: json['objetivo'],
        goalId: json['idObjetivo'].toString(),
        completedStatus: json['estado_completado'],
        number: json['numero']
      );

  Map<String, dynamic> toJson() {
    return {
      'monto_real': realAmount,
      'objetivo': plannedAmount,
      'idObjetivo': goalId,
      'estado_completado': completedStatus,
      'numero': number
    };
  }
}
