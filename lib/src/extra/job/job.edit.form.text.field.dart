import 'package:flutter/material.dart';

class JobEditFormTextField extends StatelessWidget {
  JobEditFormTextField({
    required this.controller,
    required this.label,
    required this.validator,
    required this.formKey,
    this.keyboardType,
    this.maxLines,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final GlobalKey<FormState> formKey;
  final TextInputType? keyboardType;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        minLines: maxLines != null ? 1 : null,
        maxLines: maxLines,
        validator: validator,
        onChanged: (v) => formKey.currentState!.validate(),
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
