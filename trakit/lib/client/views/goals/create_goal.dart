import 'package:flutter/material.dart';

class CreateGoalView extends StatefulWidget {
  final String mode; // "fijo" or "incremental"

  const CreateGoalView({super.key, required this.mode});

  @override
  State<CreateGoalView> createState() => _CreateGoalViewState();
}

class _CreateGoalViewState extends State<CreateGoalView> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController incrementalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isFixed = widget.mode == "fijo";
    final isIncremental = widget.mode == "incremental";

    // APPBAR TITLE
    final String appBarTitle = isFixed
        ? "Crear Objetivo Fijo"
        : "Crear Objetivo Incremental";

    // MODE DESCRIPTION
    final String modeDescription = isFixed
        ? "Este objetivo usará un monto fijo que aportarás cada semana."
        : "Este objetivo iniciará con un monto base y aumentará semanalmente.";

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nuevo Objetivo",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // DESCRIPTION DEPENDING ON MODE
            Text(
              modeDescription,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 25),

            _label("Título del objetivo"),
            _inputField(
              controller: titleController,
              hint: "Ej: Fondo para viaje",
            ),

            const SizedBox(height: 20),

            _label("Descripción"),
            _inputField(
              controller: descriptionController,
              hint: "Agrega una breve descripción...",
              maxLines: 3,
            ),

            const SizedBox(height: 25),

            // MODE-SPECIFIC INPUTS
            if (isFixed) _buildFixedModeFields(),
            if (isIncremental) _buildIncrementalModeFields(),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  // TODO: save
                },
                child: const Text(
                  "Crear Objetivo",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FIXED MODE
  Widget _buildFixedModeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Meta final"),
        _inputField(
          controller: amountController,
          hint: "Ej: 10,000",
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  // INCREMENTAL MODE
  Widget _buildIncrementalModeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Meta final"),
        _inputField(
          controller: amountController,
          hint: "Ej: 10,000",
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 20),

        _label("Incremento por semana"),
        _inputField(
          controller: incrementalController,
          hint: "Ej: 10",
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  // WIDGET HELPERS
  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}
