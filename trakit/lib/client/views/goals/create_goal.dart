import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trakit/client/components/utils.dart';
import 'package:trakit/client/models/goal.dart';
import 'package:trakit/src/firebase/firestore_service.dart';

class CreateGoalView extends StatefulWidget {
  final String mode;

  const CreateGoalView({super.key, required this.mode});

  @override
  State<CreateGoalView> createState() => _CreateGoalViewState();
}

class _CreateGoalViewState extends State<CreateGoalView> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController incrementalController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  bool _saving = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    incrementalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFixed = widget.mode == "fijo";
    final isIncremental = widget.mode == "incremental";

    final String appBarTitle = isFixed
        ? "Crear Objetivo Fijo"
        : "Crear Objetivo Incremental";

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
                onPressed: _saving ? null : _handleSave,
                child: _saving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
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

  Widget _buildFixedModeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Monto fijo"),
        _inputField(
          controller: amountController,
          hint: "Ej: 10,000",
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildIncrementalModeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Monto inicial"),
        _inputField(
          controller: amountController,
          hint: "Ej: 10,000",
          keyboardType: TextInputType.number,
        )
      ],
    );
  }

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

  Future<void> _handleSave() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final amountText = amountController.text.trim();
    final incrementText = incrementalController.text.trim();

    if (title.isEmpty) {
      Utils.showSnackBar(
        context: context,
        title: "El título del objetivo es obligatorio",
        color: Colors.red,
      );
      return;
    }

    if (description.isEmpty) {
      Utils.showSnackBar(
        context: context,
        title: "La descripción es obligatoria",
        color: Colors.red,
      );
      return;
    }

    if (amountText.isEmpty) {
      Utils.showSnackBar(
        context: context,
        title: "El monto es obligatorio",
        color: Colors.red,
      );
      return;
    }

    setState(() => _saving = true);
    double targetAmount = 0;
    if (widget.mode == "fijo") {
      targetAmount = double.parse(amountText) * 52;
    } else if (widget.mode == "incremental") {
      targetAmount = double.parse(amountText) * 1378; // suma de 1 a 52
    }

    try {
      final goal = Goal(
        id: '',
        goalType: widget.mode,
        targetAmount: targetAmount,
        userId: _firestoreService.currentUserId ?? '',
        title: title,
        description: description,
        startDate: DateTime.now().toIso8601String()
      );

      final newId = await _firestoreService.createGoal(goal, double.parse(amountText));

      if (!mounted) return;

      if (newId != null) {
        Utils.showSnackBar(
          context: context,
          title: "Objetivo creado correctamente",
          color: Colors.green,
        );
        context.pushNamed('home');
      } else {
        Utils.showSnackBar(
          context: context,
          title: "Ocurrió un error al crear el objetivo",
          color: Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Utils.showSnackBar(
        context: context,
        title: "Error inesperado: $e",
        color: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
