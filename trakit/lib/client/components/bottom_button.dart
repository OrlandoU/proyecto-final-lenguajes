import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BottomButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: Colors.green.shade800),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.green.shade900, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
