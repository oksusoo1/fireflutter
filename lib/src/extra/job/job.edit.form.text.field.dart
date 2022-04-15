import 'package:flutter/material.dart';

class JobEditFormTextField extends StatelessWidget {
  JobEditFormTextField({
    required this.label,
    required this.validator,
    this.initialValue,
    this.controller,
    required this.onChanged,
    this.keyboardType,
    this.maxLines,
    this.autoValidateMode = AutovalidateMode.onUserInteraction,
    Key? key,
  }) : super(key: key);

  final String label;
  final String? Function(String?) validator;
  final String? initialValue;
  final TextEditingController? controller;
  final Function(String) onChanged;
  final TextInputType? keyboardType;
  final int? maxLines;
  final AutovalidateMode autoValidateMode;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    );
    final errorBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    );

    return TextFormField(
      key: UniqueKey(),
      initialValue: initialValue,
      controller: controller,
      autovalidateMode: autoValidateMode,
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
