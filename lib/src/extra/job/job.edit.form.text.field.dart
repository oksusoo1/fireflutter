import 'package:flutter/material.dart';

/// sample use
///    JobEditFormTextField(
///      label: "Company name",
///      initialValue: '',
///      onChanged: (v) => '',
///      validator: (v) => validateFieldStringValue(v, FormErrorCodes.companyName),
///    ),
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
  final Function(String?) onChanged;
  final TextInputType? keyboardType;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        initialValue: initialValue,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: keyboardType,
        minLines: maxLines != null ? 1 : null,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
