import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trakit/src/firebase/firestore_service.dart';
import 'package:trakit/client/models/goal.dart';
import 'package:trakit/client/models/week.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<Goal>>(
        stream: _firestoreService.goalsStream(),
        builder: (context, snapshotGoals) {
          if (snapshotGoals.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshotGoals.hasError || !snapshotGoals.hasData) {
            return Center(
              child: Text(
                "Error al cargar objetivos",
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          final goals = snapshotGoals.data!;
          if (goals.isEmpty) {
            return Center(
              child: Text(
                "No tienes objetivos registrados",
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          final Goal activeGoal =
              goals.first; // Tomamos el primer objetivo como activo

          return StreamBuilder<List<Week>>(
            stream: _firestoreService.weeksStreamByGoal(activeGoal.id),
            builder: (context, snapshotWeeks) {
              if (snapshotWeeks.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final weeks = snapshotWeeks.data ?? [];

              // --- Cálculos ---
              double totalContributed = weeks.fold(
                0.0,
                (sum, w) => sum + w.realAmount,
              );
              double progressPercent = activeGoal.targetAmount > 0
                  ? (totalContributed / activeGoal.targetAmount) * 100
                  : 0;

              int completedWeeks = weeks.where((w) => w.completedStatus).length;

              // Datos para gráfico de línea
              final chartSpots = weeks
                  .asMap()
                  .entries
                  .map(
                    (entry) => FlSpot(
                      (entry.key + 1).toDouble(),
                      entry.value.realAmount,
                    ),
                  )
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saludo
                    Text(
                      "Hola 👋",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Resumen de tu progreso en '${activeGoal.title}'",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Progreso general
                    _summaryCard(
                      context,
                      icon: Icons.auto_graph,
                      title: "Progreso general",
                      description:
                          "Has completado $completedWeeks de 52 semanas",
                      value: "${progressPercent.toStringAsFixed(0)}%",
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(height: 20),

                    // Gráfico de línea: progreso semanal
                    if (chartSpots.isNotEmpty)
                      _chartCard(
                        context,
                        title: "Progreso semanal",
                        chart: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                spots: chartSpots,
                                barWidth: 4,
                                color: Colors.green.shade700,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade700.withOpacity(0.4),
                                      Colors.green.shade700.withOpacity(0.0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Ahorro acumulado
                    _summaryCard(
                      context,
                      icon: Icons.savings_rounded,
                      title: "Ahorro acumulado",
                      description:
                          "L. ${totalContributed.toStringAsFixed(0)} de un total esperado de L. ${activeGoal.targetAmount.toStringAsFixed(0)}",
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(height: 20),

                    // Objetivo activo
                    _summaryCard(
                      context,
                      icon: Icons.flag_rounded,
                      title: "Objetivo activo",
                      description:
                          "${activeGoal.title} · Progreso: ${progressPercent.toStringAsFixed(0)}%",
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(height: 24),

                    // Gráfico de pastel: distribución de semanas completadas
                    if (weeks.isNotEmpty)
                      _chartCard(
                        context,
                        title: "Distribución de semanas",
                        chart: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                color: Colors.green,
                                value: completedWeeks.toDouble(),
                                title:
                                    "${((completedWeeks / weeks.length) * 100).toStringAsFixed(0)}%",
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                color: Colors.grey.shade300,
                                value: (weeks.length - completedWeeks)
                                    .toDouble(),
                                title: "",
                                radius: 50,
                              ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 30,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Semanas recientes
                    Text(
                      "Semanas recientes",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...weeks.reversed
                        .take(5)
                        .map(
                          (w) => _weekItem(
                            context,
                            week: w.number,
                            amount:
                                "L. ${w.realAmount.toStringAsFixed(0)} / L. ${w.plannedAmount.toStringAsFixed(0)}",
                            completed: w.completedStatus,
                          ),
                        )
                        .toList(),
                    const SizedBox(height: 60),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    String? value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 34, color: color),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (value != null)
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chartCard(
    BuildContext context, {
    required String title,
    required Widget chart,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 180, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _weekItem(
    BuildContext context, {
    required int week,
    required String amount,
    required bool completed,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? Colors.green.shade700 : Colors.grey,
          size: 30,
        ),
        title: Text("Semana $week"),
        subtitle: Text("Monto: $amount"),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
