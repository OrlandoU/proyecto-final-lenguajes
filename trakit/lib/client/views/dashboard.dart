import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, Orlando 👋",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Aquí tienes un resumen de tu progreso.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Icon(
                        Icons.auto_graph,
                        size: 34,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Progreso general",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Has completado 30 de 52 semanas.",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "58%",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Progreso semanal",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineTouchData: LineTouchData(
                            handleBuiltInTouches: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (touchedSpots) =>
                                  touchedSpots.map((spot) {
                                    return LineTooltipItem(
                                      '${spot.y.toInt()}',
                                      theme.textTheme.bodySmall!.copyWith(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              spots: [
                                const FlSpot(0, 20),
                                const FlSpot(1, 30),
                                const FlSpot(2, 40),
                                const FlSpot(3, 38),
                                const FlSpot(4, 50),
                                const FlSpot(5, 58),
                              ],
                              barWidth: 4,
                              color: Colors.green.shade700,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.savings_rounded,
                        size: 34,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ahorro acumulado",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "L. 3,250 de un total esperado de L. 5,200",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.flag_rounded,
                    color: Colors.green.shade700,
                    size: 32,
                  ),
                ),
                title: Text(
                  "Objetivo activo",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text("Viaje a Roatán · Progreso: 42%"),
              ),
            ),

            const SizedBox(height: 30),
            Text(
              "Semanas recientes",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _weekItem(context, week: 29, amount: "L. 100", completed: true),
            _weekItem(context, week: 30, amount: "L. 100", completed: true),
            _weekItem(context, week: 31, amount: "L. 100", completed: false),

            const SizedBox(height: 60),
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
      child: ListTile(
        leading: Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
          size: 30,
        ),
        title: Text("Semana $week"),
        subtitle: Text("Monto: $amount"),
        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.outline),
      ),
    );
  }
}
