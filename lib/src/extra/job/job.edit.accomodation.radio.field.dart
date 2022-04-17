import 'package:flutter/material.dart';

class JobEditAccomodationRadioField extends FormField<String> {
  JobEditAccomodationRadioField({
    String label = "Includes accomodation?",
    required FormFieldValidator<String> validator,
    required Function(String?) onChanged,
    String initialValue = '',
  }) : super(
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          initialValue: initialValue,
          onSaved: onChanged,
          builder: (state) {
            updateValue(String v) {
              state.didChange(v);
              state.save();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ListTile(
                        dense: true,
                        title: const Text('Yes'),
                        leading: Radio<String>(
                          value: "Y",
                          groupValue: state.value,
                          onChanged: (v) => updateValue("Y"),
                        ),
                        onTap: () => updateValue("Y"),
                        selected: state.value == "Y",
                        selectedTileColor: Colors.grey.shade100,
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        dense: true,
                        title: const Text('No'),
                        leading: Radio<String>(
                          value: 'N',
                          groupValue: state.value,
                          onChanged: (v) => updateValue("N"),
                        ),
                        onTap: () => updateValue("N"),
                        selected: state.value == "N",
                        selectedTileColor: Colors.grey.shade100,
                      ),
                    ),
                  ],
                ),
                if (state.hasError)
                  Text(
                    "${state.errorText}",
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            );
          },
        );
}
