import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trakit/client/components/navigationBar.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final hasFloatingButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Aquí puedes ver tu progreso, iniciar nuevos objetivos y acceder a las herramientas principales.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: hasFloatingButton ? 80 : 28),

            // Quick actions
            Text(
              'Acciones rápidas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),

            Row(
              children: [
                _QuickActionCard(
                  icon: Icons.flag,
                  title: 'Nuevo objetivo',
                  color: Colors.green,
                  onTap: () {
                    context.pushNamed('new_goal');
                  },
                ),
                SizedBox(width: 12),
                _QuickActionCard(
                  icon: Icons.auto_graph,
                  title: 'Objetivos',
                  color: Colors.blue,
                  onTap: () {
                    context.pushNamed('goals');
                  },
                ),
              ],
            ),

            SizedBox(height: 28),

            // Featured section
            Text(
              'Resumen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),

            _SummaryCard(),

            SizedBox(height: 28),

            // Suggestions or insights
            Text(
              'Sugerencias',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            _SuggestionCard(),
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

  _QuickActionCard({
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
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tus objetivos activos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('2 completados esta semana'),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.flag, color: Colors.blue),
              SizedBox(width: 8),
              Text('1 objetivo en progreso'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
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
