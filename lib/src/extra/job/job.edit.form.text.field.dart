import 'package:flutter/material.dart';

class JobEditFormTextField extends StatelessWidget {
  JobEditFormTextField({
    required this.label,
    required this.validator,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType,
    this.maxLines,
    Key? key,
  }) : super(key: key);

  final String label;
  final String? Function(String?) validator;
  final String initialValue;
  final Function(String) onChanged;
  final TextInputType? keyboardType;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    );
    final errorBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    );

    return TextFormField(
      initialValue: initialValue,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: keyboardType,
      minLines: maxLines != null ? 1 : null,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        focusedBorder: border,
        enabledBorder: border,
        focusedErrorBorder: errorBorder,
        errorBorder: errorBorder,
      ),
    );
  }
}
