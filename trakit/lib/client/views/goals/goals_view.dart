import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoalsView extends StatelessWidget {
  const GoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample goals more aligned with the app
    final List<Map<String, dynamic>> sampleGoals = [
      {
        "title": "Viaje a Roatán",
        "description": "Ahorrar L. 5,200 para vacaciones de verano.",
        "progress": 0.42,
        "type": "Incremental",
      },
      {
        "title": "Fondo de Emergencia",
        "description": "Ahorrar L. 10,000 para imprevistos.",
        "progress": 0.3,
        "type": "Fijo",
      },
      {
        "title": "Nuevo Celular",
        "description": "Ahorrar L. 15,000 para comprar un smartphone.",
        "progress": 0.6,
        "type": "Fijo",
      },
      {
        "title": "Curso de Inglés",
        "description": "Ahorrar L. 2,500 para matrícula y materiales.",
        "progress": 0.25,
        "type": "Incremental",
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Objetivos"), centerTitle: true),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sampleGoals.length,
        itemBuilder: (context, index) {
          final goal = sampleGoals[index];

          return _goalCard(
            title: goal["title"],
            description: goal["description"],
            progress: goal["progress"],
            type: goal["type"],
            onTap: ()=> context.pushNamed('goal-details'),
          );
        },
      ),
    );
  }

  // ---------------------------------------
  // GOAL CARD WIDGET
  // ---------------------------------------
  Widget _goalCard({
    required String title,
    required String description,
    required double progress,
    required String type,
    required VoidCallback onTap,
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
            // Title & Type Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      
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
              ],
            ),
      
            const SizedBox(height: 10),
      
            Text(
              description,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
      
            const SizedBox(height: 20),
      
            // PROGRESS BAR
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
