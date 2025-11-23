import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

class GoalDetailsView extends StatefulWidget {
  const GoalDetailsView({super.key});

  @override
  State<GoalDetailsView> createState() => _GoalDetailsViewState();
}

class _GoalDetailsViewState extends State<GoalDetailsView> {
  final Map<String, dynamic> goal = {
    "title": "Viaje a Roatán",
    "description": "Ahorra L. 5,200 para tus vacaciones de verano.",
    "target": 5200.0,
  };

  late List<Map<String, dynamic>> weeks;

  @override
  void initState() {
    super.initState();
    weeks = List.generate(12, (index) {
      final completed = index < 7;
      final amount = 100 + (index * 50);
      return {
        "week": index + 1,
        "amount": amount.toDouble(),
        "completed": completed,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentWeekIndex = weeks.indexWhere((w) => !(w['completed'] as bool));
    final currentWeek = currentWeekIndex + 1;

    final totalContributed = weeks.fold<double>(
      0,
      (sum, w) =>
          sum + ((w['completed'] as bool) ? (w['amount'] as double) : 0),
    );

    final totalProgressPercent =
        (totalContributed / (goal['target'] as double)) * 100;

    final currentWeekAmount = weeks[currentWeekIndex]['amount'] as double;
    final currentWeekProgressPercent = (currentWeekAmount / 300) * 100;

    return Scaffold(
      appBar: AppBar(title: Text(goal['title']), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal info
            Text(
              goal['title'],
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              goal['description'],
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // --- TOTAL PROGRESS OUTSIDE CARD ---
            // --- TOTAL PROGRESS OUTSIDE CARD ---
            Text(
              "Progreso total: ${totalProgressPercent.toStringAsFixed(0)}% (L. ${totalContributed.toStringAsFixed(0)} de L. ${goal['target']})",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: totalProgressPercent / 100,
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xFF2ECC71),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              "Progreso General: ${totalProgressPercent.toStringAsFixed(0)}%",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: totalProgressPercent / 100,
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
                color: const Color.fromARGB(255, 46, 133, 204),
              ),
            ),
            const SizedBox(height: 16),
            // --- NUEVAS SECCIONES AÑADIDAS ---
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
                  "Total esperado: L. ${goal['target'].toStringAsFixed(0)}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),


            const SizedBox(height: 16),

            // Current Week Progress Card
            _progressCard(
              title: "Progreso semana $currentWeek",
              progressPercent: currentWeekProgressPercent,
              contributed: currentWeekAmount,
              target: 300.0,
              showButton: true,
              onButtonPressed: () {
                setState(() {
                  weeks[currentWeekIndex]['completed'] = true;
                });
              },
            ),

            const SizedBox(height: 20),

            // Line Chart
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
                          spots: weeks
                              .asMap()
                              .entries
                              .map(
                                (e) => FlSpot(
                                  e.key.toDouble(),
                                  e.value['amount'] as double,
                                ),
                              )
                              .toList(),
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

            ...weeks.map(
              (w) => _weekItem(
                context,
                week: w['week'] as int,
                amount: "L. ${(w['amount'] as double).toStringAsFixed(0)}",
                completed: w['completed'] as bool,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _progressCard({
    required String title,
    required double progressPercent,
    required double contributed,
    required double target,
    bool showButton = false,
    VoidCallback? onButtonPressed,
  }) {
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
              Container(
                height: 20,
                width:
                    MediaQuery.of(context).size.width *
                        (progressPercent / 100) -
                    32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text("${progressPercent.toStringAsFixed(0)}% completado"),
          Text("Monto aportado: L. ${contributed.toStringAsFixed(0)}"),
          if (showButton)
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
                  child: GestureDetector(
                    onTap: () => {
                      context.pushNamed('week-update')
                    },
                    child: const Text(
                      "Registrar aporte",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
