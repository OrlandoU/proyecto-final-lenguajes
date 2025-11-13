class Week {
  final String id;
  final int realAmount;
  final int plannedAmount;
  final String goalId;
  final int completedStatus;

  Week({
    required this.id,
    required this.realAmount,
    required this.plannedAmount,
    required this.goalId,
    required this.completedStatus,
  });

  factory Week.fromJson(Map<String, dynamic> json) => Week(
        id: json['id'].toString(),
        realAmount: json['monto_real'],
        plannedAmount: json['objetivo'],
        goalId: json['idObjetivo'].toString(),
        completedStatus: json['estado_completado'],
      );

  Map<String, dynamic> toJson() {
    return {
      'monto_real': realAmount,
      'objetivo': plannedAmount,
      'idObjetivo': goalId,
      'estado_completado': completedStatus,
    };
  }
}
