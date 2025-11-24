import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trakit/client/models/goal.dart';
import 'package:trakit/client/models/week.dart';
import 'package:trakit/client/components/utils.dart';
import 'package:trakit/src/firebase/firestore_service.dart';

class GoalsView extends StatelessWidget {
  GoalsView({super.key});

  final user = FirebaseAuth.instance.currentUser;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Objetivos"), centerTitle: true),
      body: StreamBuilder<List<Goal>>(
        stream: _firestoreService.goalsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ocurrió un error al cargar tus objetivos',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final goals = snapshot.data ?? [];

          if (goals.isEmpty) {
            return const Center(
              child: Text(
                'Aún no has creado objetivos.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];

              return StreamBuilder<List<Week>>(
                stream: _firestoreService.weeksStreamByGoal(goal.id),
                builder: (context, weekSnapshot) {
                  final weeks = weekSnapshot.data ?? [];

                  final double progress = _calculateProgress(goal, weeks);

                  final String type =
                      goal.goalType.toLowerCase() == 'incremental'
                          ? 'Incremental'
                          : 'Fijo';

                  return _goalCard(
                    title: goal.title,
                    description: goal.description,
                    progress: progress,
                    type: type,
                    onTap: () {
                      context.pushNamed(
                        'goal-details',
                        extra: goal,
                      );
                    },
                    onDelete: () {
                      Utils.showConfirm(
                        context: context,
                        confirmButton: () async {
                          final success =
                              await _firestoreService.deleteGoal(goal.id);

                          Navigator.of(context).pop();

                          if (success) {
                            Utils.showSnackBar(
                              context: context,
                              title: 'Objetivo eliminado correctamente',
                              color: Colors.green,
                            );
                          } else {
                            Utils.showSnackBar(
                              context: context,
                              title: 'No se pudo eliminar el objetivo',
                              color: Colors.red,
                            );
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  double _calculateProgress(Goal goal, List<Week> weeks) {
    final double target = goal.targetAmount;

    if (target <= 0) return 0;

    final double totalReal = weeks.fold<double>(
      0,
      (prev, w) => prev + (w.realAmount.toDouble()),
    );

    final progress = totalReal / target;
    if (progress < 0) return 0;
    if (progress > 1) return 1;
    return progress;
  }

  Widget _goalCard({
    required String title,
    required String description,
    required double progress,
    required String type,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withOpacity(.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      color: Color(0xFF2ECC71),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Eliminar objetivo',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xFF2ECC71),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${(progress * 100).toStringAsFixed(0)}% completado",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
