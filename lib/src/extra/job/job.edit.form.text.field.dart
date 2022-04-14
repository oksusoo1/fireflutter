import 'package:flutter/material.dart';

class JobEditFormTextField extends StatelessWidget {
  JobEditFormTextField({
    required this.controller,
    required this.label,
    required this.onUnfocus,
    required this.errorMessage,
    this.keyboardType,
    this.maxLines,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;
  final Function() onUnfocus;
  final TextInputType? keyboardType;
  final String? errorMessage;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Focus(
        onFocusChange: (b) {
          if (!b) onUnfocus();
        },
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: maxLines != null ? 1 : null,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            errorText: errorMessage,
            errorStyle: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
    );
  }
}
