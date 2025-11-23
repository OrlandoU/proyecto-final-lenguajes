import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trakit/client/components/bottom_button.dart';
import 'package:trakit/client/components/mode_option.dart';
import 'package:trakit/client/components/navigationBar.dart';

class SelectGoalView extends StatelessWidget {
  const SelectGoalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TrakIt'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            const SizedBox(height: 10),

            /// Título superior
            const Text(
              'Elige tu modalidad de ahorro',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            const Text(
              'Selecciona cómo deseas ahorrar durante las 52 semanas.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            SizedBox(height: 20),

            /// Modalidad 1: Monto fijo
            ModeOption(
              title: 'Monto Fijo Semanal',
              description:
                  'Ahorra el mismo monto cada semana durante 52 semanas.',
              icon: Icons.attach_money,
              onTap: () {
                context.pushNamed('create-goal', extra: 'fijo');
              },
            ),
            const SizedBox(height: 16),

            /// Modalidad 2: Incremental
            ModeOption(
              title: 'Ahorro Incremental',
              description:
                  'El monto aumenta cada semana según el valor inicial.',
              icon: Icons.trending_up,
              onTap: () {
                context.pushNamed('create-goal', extra: 'incremental');
              },
            ),

            const Spacer(),

            /// Barra inferior de navegación
          ],
        ),
      ),
      // bottomNavigationBar: NavigationbarE()
    );
  }
}


