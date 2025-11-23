import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import 'package:trakit/client/models/goal.dart';
import 'package:trakit/client/models/week.dart';
import 'package:trakit/src/firebase/firestore_service.dart';

class GoalDetailsView extends StatefulWidget {
  final Goal goal;

  const GoalDetailsView({super.key, required this.goal});

  @override
  State<GoalDetailsView> createState() => _GoalDetailsViewState();
}

class _GoalDetailsViewState extends State<GoalDetailsView> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.goal.title), centerTitle: true),
      body: StreamBuilder<List<Week>>(
        stream: _firestoreService.weeksStreamByGoal(widget.goal.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar las semanas',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final weeks = snapshot.data ?? [];

          // --- Cálculos de progreso ---
          final double target = _parseTarget(widget.goal.targetAmount);
          final double totalContributed = weeks.fold<double>(
            0,
            (sum, w) => sum + w.realAmount.toDouble(),
          );
          final double totalProgressPercent = target > 0
              ? (totalContributed / target) * 100
              : 0;

          // Semana actual: primera con completedStatus == 0, si no hay, siguiente
          int currentWeekIndex = weeks.indexWhere(
            (w) => w.completedStatus == 0,
          );

          if (weeks.isEmpty) {
            currentWeekIndex = 0;
          } else if (currentWeekIndex == -1) {
            currentWeekIndex = weeks.length - 1;
          }

          final int currentWeekNumber = weeks.isEmpty
              ? 1
              : (currentWeekIndex + 1);

          // Datos de la "semana actual"
          double currentWeekAmount = 0;
          double currentWeekTarget = 0;
          double currentWeekProgressPercent = 0;

          if (weeks.isNotEmpty) {
            final week = weeks[currentWeekIndex];
            currentWeekAmount = week.realAmount.toDouble();
            currentWeekTarget = week.plannedAmount.toDouble();
            if (currentWeekTarget > 0) {
              currentWeekProgressPercent =
                  (currentWeekAmount / currentWeekTarget) * 100;
            }
          } else {
            // Si no hay semanas aún, asumimos un target proporcional (ej: /12)
            currentWeekTarget = target > 0 ? target / 12 : 0;
            currentWeekAmount = 0;
            currentWeekProgressPercent = 0;
          }

          // Lista para el gráfico (usamos numero de semana como X)
          final chartSpots = weeks.isEmpty
              ? <FlSpot>[]
              : weeks.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final w = entry.value;
                  return FlSpot((idx + 1).toDouble(), w.realAmount.toDouble());
                }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Goal info
                Text(
                  widget.goal.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.goal.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                // Progreso total
                Text(
                  "Progreso total: ${totalProgressPercent.toStringAsFixed(0)}% "
                  "(L. ${totalContributed.toStringAsFixed(0)} de L. ${target.toStringAsFixed(0)})",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (totalProgressPercent.clamp(0, 100)) / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade300,
                    color: const Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  "Progreso general: ${totalProgressPercent.toStringAsFixed(0)}%",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (totalProgressPercent.clamp(0, 100)) / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade300,
                    color: const Color.fromARGB(255, 46, 133, 204),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total ahorrado: L. ${totalContributed.toStringAsFixed(0)}",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Total esperado: L. ${target.toStringAsFixed(0)}",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Card de progreso semana actual
                _progressCard(
                  context: context,
                  title: "Progreso semana $currentWeekNumber",
                  progressPercent: currentWeekProgressPercent,
                  contributed: currentWeekAmount,
                  target: currentWeekTarget,
                  showButton: true,
                  onButtonPressed: () {
                    _openWeekUpdate(
                      weekNumber: currentWeekNumber,
                      expectedAmount: currentWeekTarget,
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Line Chart
                if (chartSpots.isNotEmpty)
                  Container(
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
                      child: SizedBox(
                        height: 180,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineTouchData: LineTouchData(
                              handleBuiltInTouches: true,
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (spots) => spots.map((spot) {
                                  return LineTooltipItem(
                                    "L. ${spot.y.toInt()}",
                                    theme.textTheme.bodySmall!.copyWith(
                                      color: Colors.black,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                spots: chartSpots,
                                barWidth: 4,
                                color: const Color(0xFF2ECC71),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
                Text(
                  "Semanas",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (weeks.isEmpty)
                  const Text(
                    "Aún no has registrado semanas para este objetivo.",
                  ),
                ...weeks.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final w = entry.value;
                  return _weekItem(
                    context,
                    week: idx + 1,
                    amount:
                        "L. ${w.realAmount.toStringAsFixed(0)} / L. ${w.plannedAmount.toStringAsFixed(0)}",
                    completed: w.completedStatus == 1,
                  );
                }),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  double _parseTarget(String raw) {
    final cleaned = raw.replaceAll('L', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0;
  }

  void _openWeekUpdate({
    required int weekNumber,
    required double expectedAmount,
  }) {
    context.pushNamed(
      'week-update',
      extra: {
        'goalId': widget.goal.id,
        'week': weekNumber,
        'expectedAmount': expectedAmount,
      },
    );
  }

  Widget _progressCard({
    required BuildContext context,
    required String title,
    required double progressPercent,
    required double contributed,
    required double target,
    bool showButton = false,
    VoidCallback? onButtonPressed,
  }) {
    final width = MediaQuery.of(context).size.width;
    final clampedPercent = progressPercent.clamp(0, 100);
    final barWidth = (width - 32) * (clampedPercent / 100);

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 20,
                width: barWidth,
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text("${clampedPercent.toStringAsFixed(0)}% completado"),
          Text(
            "Monto aportado: L. ${contributed.toStringAsFixed(0)} "
            "/ L. ${target.toStringAsFixed(0)}",
          ),
          if (showButton && onButtonPressed != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Registrar aporte",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _weekItem(
    BuildContext context, {
    required int week,
    required String amount,
    required bool completed,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? const Color(0xFF2ECC71) : Colors.grey,
          size: 30,
        ),
        title: Text("Semana $week"),
        subtitle: Text("Monto: $amount"),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
