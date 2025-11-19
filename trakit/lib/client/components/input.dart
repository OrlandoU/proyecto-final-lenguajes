import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final bool escondible;
  final int maxLines;
  final FocusNode? focusNode;
  final Widget? prefixIcon;

  bool estaVisible = true;

  Input({
    super.key,
    required this.label,
    required this.controller,
    this.escondible = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.maxLines = 1,
    this.focusNode,
    this.prefixIcon,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      maxLines: widget.maxLines,
      controller: widget.controller,
      obscureText: !widget.estaVisible,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon,
        label: Text(widget.label),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
        suffixIcon: widget.escondible
            ? IconButton(
                icon: Icon(
                  !widget.estaVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    widget.estaVisible = !widget.estaVisible;
                  });
                },
              )
            : null,
      ),
    );
  }
}
