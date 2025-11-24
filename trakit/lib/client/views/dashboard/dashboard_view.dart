// dashboard_view.dart
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
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

  // Utility: format money (simple)
  String _fmt(double value) {
    if (value >= 1000) {
      return value
          .toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<Goal>>(
        stream: _firestoreService.goalsStream(),
        builder: (context, goalsSnapshot) {
          if (goalsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (goalsSnapshot.hasError) {
            return Center(
              child: Text(
                'Error cargando objetivos',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          final goals = goalsSnapshot.data ?? [];
          if (goals.isEmpty) {
            return Center(
              child: Text(
                'No tienes objetivos registrados',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          // Aggregate data across ALL goals (async)
          return FutureBuilder<_AggregateAll>(
            future: _aggregateAllGoals(goals),
            builder: (context, aggSnap) {
              if (aggSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (aggSnap.hasError || !aggSnap.hasData) {
                return Center(
                  child: Text(
                    'Error calculando datos',
                    style: theme.textTheme.bodyLarge,
                  ),
                );
              }

              final agg = aggSnap.data!;
              // MAIN UI
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hola 👋',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Resumen general — ${goals.length} objetivos',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: FirebaseAuth.instance.currentUser?.photoURL != null
                              ? NetworkImage(
                                  FirebaseAuth.instance.currentUser!.photoURL!)
                              : const AssetImage('assets/avatar.png')
                                    as ImageProvider,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Small stat cards row
                    Column(
                      children: [
                        Container(
                          child: _smallStatCard(
                            'Objetivos',
                            goals.length.toString(),
                            Icons.flag_rounded,
                            context,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          child: _smallStatCard(
                            'Ahorro total',
                            'L. ${_fmt(agg.totalSaved)}',
                            Icons.savings_rounded,
                            context,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          child: _smallStatCard(
                            'Semanas totales',
                            agg.totalWeeks.toString(),
                            Icons.calendar_month,
                            context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Global progress
                    _bigProgressCard(
                      context,
                      label: 'Progreso global',
                      percent: agg.globalProgressPercent.clamp(0, 100) / 100,
                      subtitle:
                          'L. ${_fmt(agg.totalSaved)} de L. ${_fmt(agg.totalExpected)}',
                    ),
                    const SizedBox(height: 18),

                    // Charts row: Line + Pie + Top goal mini
                    // Wrap the row in a fixed height container so children can use Expanded safely
                    // Contenedor principal vertical
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Gráfico de línea (global weekly sums)
    _chartCard(
      context,
      title: 'Aporte por semana (global)',
      chart: _lineChart(agg.weeklySums),
    ),
    const SizedBox(height: 20),

    // Pie chart: semanas completadas
    _chartCard(
      context,
      title: 'Semanas completadas',
      chart: _pieChart(
        agg.completedWeeks.toDouble(),
        max(agg.totalWeeks - agg.completedWeeks, 0).toDouble(),
      ),
    ),
    const SizedBox(height: 20),

    // Mini info card
    _miniListCard(
      context,
      title: 'Top objetivo',
      subtitle: agg.bestGoalName != null
          ? '${agg.bestGoalName!} · ${agg.bestGoalPercent.toStringAsFixed(0)}%'
          : '—',
      icon: Icons.emoji_events,
      color: Colors.purple.shade700,
    ),
  ],
),

                    const SizedBox(height: 20),

                    // Bar chart comparing goals
                    _chartCard(
                      context,
                      title: 'Comparativa por objetivo (monto aportado)',
                      chart: _barChart(agg.perGoalStats),
                    ),
                    const SizedBox(height: 16),

                    // Top 5 weeks across all goals
                    _sectionTitle('Top 5 semanas (mayor aporte)', context),
                    const SizedBox(height: 8),
                    ...agg.topWeeks
                        .map(
                          (t) => _topWeekTile(
                            context,
                            t.goalTitle,
                            t.weekNumber,
                            t.amount,
                          ),
                        )
                        .toList(),
                    const SizedBox(height: 16),

                    // Goal list with progress mini cards
                    _sectionTitle('Objetivos (detalle)', context),
                    const SizedBox(height: 8),
                    Column(
                      children: agg.perGoalStats.map((g) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _goalProgressCard(context, g),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Insights
                    _sectionTitle('Insights', context),
                    const SizedBox(height: 8),
                    _insightsCard(context, agg),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ----------------------------
  // DATA AGGREGATION (ALL GOALS)
  // ----------------------------
  Future<_AggregateAll> _aggregateAllGoals(List<Goal> goals) async {
    final firestore = _firestoreService;

    // fetch weeks for each goal
    final List<List<Week>> perGoalWeeks = await Future.wait(
      goals.map((g) => firestore.getWeeksByGoal(g.id)),
    );

    final List<_WeekWithGoal> allWeeks = [];
    double totalExpected = 0;
    double totalSaved = 0;
    int completedWeeks = 0;

    // weekly map 1..52
    final Map<int, double> weeklySums = {for (var i = 1; i <= 52; i++) i: 0.0};

    final List<_GoalStat> perGoalStats = [];

    for (var i = 0; i < goals.length; i++) {
      final g = goals[i];
      final weeks = perGoalWeeks[i];
      double contributed = 0;
      double expectedForGoal = 0;

      for (var w in weeks) {
        final wk = (w.number >= 1 && w.number <= 52)
            ? w.number
            : w.number.clamp(1, 52);
        final real = w.realAmount;
        weeklySums[wk] = (weeklySums[wk] ?? 0) + real;
        contributed += real;
        expectedForGoal += w.plannedAmount;
        totalSaved += real;
        totalExpected += w.plannedAmount;
        if (w.completedStatus) completedWeeks++;
        allWeeks.add(
          _WeekWithGoal(
            goalId: g.id,
            goalTitle: g.title,
            weekNumber: wk,
            amount: real,
          ),
        );
      }

      final double pct = g.targetAmount > 0 ? (contributed / g.targetAmount) * 100 : 0;
      perGoalStats.add(
        _GoalStat(
          id: g.id,
          title: g.title,
          amount: contributed,
          target: g.targetAmount,
          percent: pct,
        ),
      );
    }

    // weekly spots
    final weeklySpotsList = weeklySums.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final weeklySpots = weeklySpotsList
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    // top 5 weeks global
    allWeeks.sort((a, b) => b.amount.compareTo(a.amount));
    final top5 = allWeeks
        .take(5)
        .map(
          (w) => _TopWeek(
            goalTitle: w.goalTitle,
            weekNumber: w.weekNumber,
            amount: w.amount,
          ),
        )
        .toList();

    // best goal by percent
    perGoalStats.sort((a, b) => b.amount.compareTo(a.amount));
    String? bestName;
    double bestPct = -1;
    for (var g in perGoalStats) {
      if (g.percent > bestPct) {
        bestPct = g.percent;
        bestName = g.title;
      }
    }

    return _AggregateAll(
      totalExpected: totalExpected,
      totalSaved: totalSaved,
      totalWeeks: allWeeks.length,
      completedWeeks: completedWeeks,
      globalProgressPercent: totalExpected > 0
          ? (totalSaved / totalExpected) * 100
          : 0,
      weeklySums: weeklySpots,
      perGoalStats: perGoalStats,
      topWeeks: top5,
      bestGoalName: bestName,
      bestGoalPercent: bestPct,
    );
  }

  // ----------------------------
  // UI helpers / small widgets
  // ----------------------------
  Widget _smallStatCard(
    String title,
    String value,
    IconData icon,
    BuildContext ctx,
  ) {
    final theme = Theme.of(ctx);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.green.shade700.withOpacity(.12),
            child: Icon(icon, color: Colors.green.shade700),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bigProgressCard(
    BuildContext ctx, {
    required String label,
    required double percent,
    required String subtitle,
  }) {
    final theme = Theme.of(ctx);
    final pct = (percent * 100).clamp(0, 100);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _chartCard(
    BuildContext ctx, {
    required String title,
    required Widget chart,
  }) {
    final theme = Theme.of(ctx);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            SizedBox(height: 160, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, BuildContext ctx) {
    return Text(
      text,
      style: Theme.of(
        ctx,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _lineChart(List<FlSpot> spots) {
    final data = spots.isNotEmpty
        ? spots
        : [const FlSpot(1, 0), const FlSpot(52, 0)];
    final maxY = data.map((s) => s.y).reduce((a, b) => max(a, b)) + 10;
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (v) =>
              FlLine(color: Colors.grey.withOpacity(.12), strokeWidth: 1),
          drawVerticalLine: false,
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 1,
        maxX: 52,
        minY: 0,
        maxY: maxY <= 0 ? 10 : maxY,
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: data,
            barWidth: 3.8,
            color: Colors.green.shade700,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade700.withOpacity(0.36),
                  Colors.green.shade700.withOpacity(0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pieChart(double completed, double pending) {
    final total = (completed + pending).clamp(1, double.infinity);
    final pct = (completed / total) * 100;
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 28,
        sections: [
          PieChartSectionData(
            color: Colors.green.shade700,
            value: completed,
            title: '${pct.toStringAsFixed(0)}%',
            radius: 46,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          PieChartSectionData(
            color: Colors.grey.shade300,
            value: pending,
            title: '',
            radius: 40,
          ),
        ],
      ),
    );
  }

  Widget _barChart(List<_GoalStat> goalsData) {
    if (goalsData.isEmpty) return const Center(child: Text('Sin datos'));
    final maxAmount = goalsData.map((g) => g.amount).reduce(max);
    return BarChart(
      BarChartData(
        maxY: maxAmount * 1.15,
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: goalsData.asMap().entries.map((entry) {
          final idx = entry.key;
          final g = entry.value;
          final color =
              Color.lerp(
                Colors.blue,
                Colors.green,
                (idx / max(1, goalsData.length - 1)),
              ) ??
              Colors.blue;
          return BarChartGroupData(
            x: idx,
            barsSpace: 6,
            barRods: [
              BarChartRodData(
                toY: g.amount,
                color: color,
                width: 14,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
            showingTooltipIndicators: [0],
          );
        }).toList(),
      ),
    );
  }

  Widget _topWeekTile(
    BuildContext ctx,
    String goalTitle,
    int weekNumber,
    double amount,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.green.shade700.withOpacity(.12),
          child: Icon(Icons.calendar_month, color: Colors.green.shade700),
        ),
        title: Text(
          goalTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Semana $weekNumber'),
        trailing: Text(
          'L. ${_fmt(amount)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _miniListCard(
    BuildContext ctx, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(ctx);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.02), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _goalProgressCard(BuildContext ctx, _GoalStat g) {
    final theme = Theme.of(ctx);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.02), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  g.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${g.percent.toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (g.percent / 100).clamp(0, 1),
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'L. ${_fmt(g.amount)} / L. ${_fmt(g.target)}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _insightsCard(BuildContext ctx, _AggregateAll agg) {
    final theme = Theme.of(ctx);
    final bullets = <Widget>[];
    if (agg.bestGoalName != null) {
      bullets.add(
        _insightRow(
          'Mejor objetivo',
          '${agg.bestGoalName} (${agg.bestGoalPercent.toStringAsFixed(0)}%)',
        ),
      );
    }
    final double avgWeek = agg.totalWeeks > 0
        ? (agg.totalSaved / agg.totalWeeks)
        : 0;
    bullets.add(
      _insightRow('Aporte promedio por semana', 'L. ${_fmt(avgWeek)}'),
    );
    final double recommended =
        ((agg.totalExpected - agg.totalSaved) / max(1, 52 - agg.completedWeeks))
            .clamp(0, double.infinity);
    if (recommended.isFinite && recommended > 0) {
      bullets.add(
        _insightRow('Recomendación', 'Aumenta L. ${_fmt(recommended)}/semana'),
      );
    } else {
      bullets.add(_insightRow('Recomendación', 'Vas bien — sigue así 👍'));
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.02), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: bullets,
      ),
    );
  }

  Widget _insightRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.bolt, color: Colors.orange.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

// -----------------------------
// DATA CLASSES
// -----------------------------
class _AggregateAll {
  final double totalExpected;
  final double totalSaved;
  final int totalWeeks;
  final int completedWeeks;
  final double globalProgressPercent;
  final List<FlSpot> weeklySums;
  final List<_GoalStat> perGoalStats;
  final List<_TopWeek> topWeeks;
  final String? bestGoalName;
  final double bestGoalPercent;

  _AggregateAll({
    required this.totalExpected,
    required this.totalSaved,
    required this.totalWeeks,
    required this.completedWeeks,
    required this.globalProgressPercent,
    required this.weeklySums,
    required this.perGoalStats,
    required this.topWeeks,
    required this.bestGoalName,
    required this.bestGoalPercent,
  });
}

class _GoalStat {
  final String id;
  final String title;
  final double amount;
  final double target;
  final double percent;

  _GoalStat({
    required this.id,
    required this.title,
    required this.amount,
    required this.target,
    required this.percent,
  });
}

class _WeekWithGoal {
  final String goalId;
  final String goalTitle;
  final int weekNumber;
  final double amount;

  _WeekWithGoal({
    required this.goalId,
    required this.goalTitle,
    required this.weekNumber,
    required this.amount,
  });
}

class _TopWeek {
  final String goalTitle;
  final int weekNumber;
  final double amount;

  _TopWeek({
    required this.goalTitle,
    required this.weekNumber,
    required this.amount,
  });
}
