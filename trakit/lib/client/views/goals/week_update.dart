import 'package:flutter/material.dart';
import 'package:trakit/client/models/week.dart';
import 'package:trakit/src/firebase/firestore_service.dart';

class SubmitWeekAmountView extends StatefulWidget {
  final int week;
  final double expectedAmount;
  final Function(double) onSubmit;
  final String? goalId;

  const SubmitWeekAmountView({
    super.key,
    required this.week,
    required this.expectedAmount,
    required this.onSubmit,
    this.goalId,
  });

  @override
  State<SubmitWeekAmountView> createState() => _SubmitWeekAmountViewState();
}

class _SubmitWeekAmountViewState extends State<SubmitWeekAmountView> {
  final TextEditingController _amountController = TextEditingController();
  String? _error;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final text = _amountController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _error = "Ingrese un monto válido";
      });
      return;
    }

    final value = double.tryParse(text.replaceAll(',', ''));
    if (value == null || value <= 0) {
      setState(() {
        _error = "Ingrese un monto numérico positivo";
      });
      return;
    }

    if (value > widget.expectedAmount) {
      setState(() {
        _error =
            "El monto no puede superar L. ${widget.expectedAmount.toStringAsFixed(0)}";
      });
      return;
    }

    setState(() {
      _error = null;
      _isSaving = true;
    });

    try {
      if (widget.goalId != null) {
        final week = Week(
          id: '',
          realAmount: value.round(),
          plannedAmount: widget.expectedAmount.round(),
          goalId: widget.goalId!,
          completedStatus: value >= widget.expectedAmount ? 1 : 0,
        );

        final createdId = await FirestoreService().createWeek(week);

        if (createdId == null) {
          setState(() {
            _error = "No se pudo registrar el aporte, inténtalo de nuevo.";
          });
          return;
        }
      }

      widget.onSubmit(value);

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Registrar aporte - Semana ${widget.week}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Monto esperado: L. ${widget.expectedAmount.toStringAsFixed(0)}",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monto a registrar",
                prefixText: "L. ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        "Registrar",
                        style: TextStyle(
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
}
