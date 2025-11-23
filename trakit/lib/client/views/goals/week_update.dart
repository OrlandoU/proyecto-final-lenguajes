import 'package:flutter/material.dart';

class SubmitWeekAmountView extends StatefulWidget {
  final int week;
  final double expectedAmount;
  final Function(double) onSubmit;

  const SubmitWeekAmountView({
    super.key,
    required this.week,
    required this.expectedAmount,
    required this.onSubmit,
  });

  @override
  State<SubmitWeekAmountView> createState() => _SubmitWeekAmountViewState();
}

class _SubmitWeekAmountViewState extends State<SubmitWeekAmountView> {
  final TextEditingController _amountController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
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

    widget.onSubmit(value);
    Navigator.pop(context); // cerrar la pantalla después de enviar
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
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
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
