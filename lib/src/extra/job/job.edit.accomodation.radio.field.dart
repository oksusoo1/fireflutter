import 'package:flutter/material.dart';

class JobEditAccomodationRadioField<T> extends FormField<String> {
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
                      child: RadioListTile<String>(
                        value: "Y",
                        groupValue: state.value,
                        title: Text('Yes'),
                        onChanged: (v) => updateValue("Y"),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        value: "N",
                        groupValue: state.value,
                        title: Text('N'),
                        onChanged: (v) => updateValue("N"),
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
