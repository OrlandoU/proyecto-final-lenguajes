import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trakit/client/components/navigationBar.dart';
import 'package:trakit/src/firebase/firestore_service.dart';
import 'package:trakit/client/models/goal.dart';
import 'package:trakit/client/models/week.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final FirestoreService _firestoreService = FirestoreService();
  final hasFloatingButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      bottomNavigationBar: NavigationbarE(hasFloatingButton: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('new_goal');
        },
        backgroundColor: Colors.green.shade700,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 32,
          weight: 900,
        ),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aquí puedes ver tu progreso, iniciar nuevos objetivos y acceder a las herramientas principales.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: hasFloatingButton ? 80 : 28),

            // Quick actions
            const Text(
              'Acciones rápidas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _QuickActionCard(
                  icon: Icons.flag,
                  title: 'Nuevo objetivo',
                  color: Colors.green,
                  onTap: () => context.pushNamed('new_goal'),
                ),
                const SizedBox(width: 12),
                _QuickActionCard(
                  icon: Icons.auto_graph,
                  title: 'Objetivos',
                  color: Colors.blue,
                  onTap: () => context.pushNamed('goals'),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Featured section: Dynamic summary
            const Text(
              'Resumen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<Goal>>(
              stream: _firestoreService.goalsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Text('Error al cargar objetivos.');
                }

                final goals = snapshot.data ?? [];
                if (goals.isEmpty) {
                  return const Text('No tienes objetivos activos todavía.');
                }

                // Calculamos progreso general
                return FutureBuilder<List<List<Week>>>(
                  future: Future.wait(
                    goals.map((g) => _firestoreService.getWeeksByGoal(g.id)),
                  ),
                  builder: (context, weeksSnapshot) {
                    if (!weeksSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allWeeks = weeksSnapshot.data!
                        .expand((w) => w)
                        .toList();

                    double totalAhorrado = 0;
                    double totalEsperado = 0;
                    int completedThisWeek = 0;

                    for (var w in allWeeks) {
                      totalAhorrado += w.realAmount;
                      totalEsperado += w.plannedAmount;

                      // Suponiendo que "completedStatus" indica completado esta semana
                      if (w.completedStatus) completedThisWeek++;
                    }

                    final progresoGeneral = totalEsperado > 0
                        ? (totalAhorrado / totalEsperado) * 100
                        : 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryCard(
                          completedThisWeek: completedThisWeek,
                          inProgress: goals.length,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Progreso general: ${progresoGeneral.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (progresoGeneral.clamp(0, 100)) / 100,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade300,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 28),

            // Suggestions or insights
            const Text(
              'Sugerencias',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const _SuggestionCard(),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int completedThisWeek;
  final int inProgress;

  const _SummaryCard({
    this.completedThisWeek = 0,
    this.inProgress = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tus objetivos activos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text('$completedThisWeek completados esta semana'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.flag, color: Colors.blue),
              const SizedBox(width: 8),
              Text('$inProgress objetivo(s) en progreso'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: const [
          Icon(Icons.lightbulb, color: Colors.green, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tip: Establecer pequeños objetivos diarios te ayudará a mantenerte nte.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
