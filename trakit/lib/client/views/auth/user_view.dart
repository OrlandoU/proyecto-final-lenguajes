import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:trakit/src/firebase/firestore_service.dart';
import 'package:trakit/client/models/goal.dart';
import 'package:trakit/client/models/week.dart';

class UserView extends StatelessWidget {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo
            Text(
              "Hola, ${user?.displayName ?? 'Usuario'} 👋",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Revisa tu perfil y estadísticas.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Tarjeta de información del usuario
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
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : const AssetImage('assets/avatar.png')
                                as ImageProvider,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Nombre de Usuario',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'email@example.com',
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

            // Estadísticas usando FutureBuilder
            FutureBuilder<Map<String, dynamic>>(
              future: _calculateStats(user?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.hasError) {
                  return const Center(
                    child: Text("Error al cargar estadísticas"),
                  );
                }

                final stats = snapshot.data!;
                return _statsCard(
                  stats['totalGoals'],
                  stats['totalSaved'],
                  stats['totalWeeksCompleted'],
                );
              },
            ),

            const SizedBox(height: 20),

            // Acciones rápidas
            Text(
              "Acciones rápidas",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _actionCard(
              icon: Icons.logout,
              title: "Cerrar sesión",
              onTap: () async {
                   await FirebaseAuth.instance.signOut(); // cierra la sesión

                if (!context.mounted) return;

                context.replace('/login');
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Función para calcular estadísticas ---
  Future<Map<String, dynamic>> _calculateStats(String userId) async {
    final firestore = FirestoreService();

    // Obtener todos los objetivos del usuario
    final goals = await firestore.getGoals(userId: userId);
    int totalGoals = goals.length;

    // Obtener todas las semanas de cada objetivo
    List<Week> allWeeks = [];
    for (var g in goals) {
      final weeks = await firestore.getWeeksByGoal(g.id);
      allWeeks.addAll(weeks);
    }

    int totalWeeksCompleted = allWeeks.where((w) => w.completedStatus).length;

    double totalSaved = allWeeks.fold(0, (sum, w) => sum + w.realAmount);

    return {
      'totalGoals': totalGoals,
      'totalWeeksCompleted': totalWeeksCompleted,
      'totalSaved': totalSaved,
    };
  }

  // --- Tarjeta de estadísticas ---
  Widget _statsCard(int goals, double saved, int completedWeeks) {
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem("Objetivos", goals.toString()),
            _statItem("Ahorro", "L. ${saved.toStringAsFixed(0)}"),
            _statItem("Semanas completadas", completedWeeks.toString()),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2ECC71),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2ECC71), size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
