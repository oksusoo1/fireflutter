import 'package:flutter/material.dart';

class JobEditAccomodationRadioField extends StatefulWidget {
  const JobEditAccomodationRadioField(
      {required this.initialValue, required this.validator, Key? key})
      : super(key: key);

  final String initialValue;
  final String? Function(dynamic) validator;

  @override
  State<JobEditAccomodationRadioField> createState() => _JobEditAccomodationRadioFieldState();
}

class _JobEditAccomodationRadioFieldState extends State<JobEditAccomodationRadioField> {
  String currentValue = '';

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
  }

  changeValue(String? v) {
    setState(() => currentValue = v ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      initialValue: widget.initialValue,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        return Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    dense: true,
                    title: const Text('Yes'),
                    leading: Radio<String>(
                      value: "Y",
                      groupValue: currentValue,
                      onChanged: changeValue,
                    ),
                    onTap: () => changeValue("Y"),
                    selected: currentValue == "Y",
                    selectedTileColor: Colors.yellow.shade100,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    dense: true,
                    title: const Text('No'),
                    leading: Radio<String>(
                      value: 'N',
                      groupValue: currentValue,
                      onChanged: changeValue,
                    ),
                    onTap: () => changeValue("N"),
                    selected: currentValue == "N",
                    selectedTileColor: Colors.yellow.shade100,
                  ),
                ),
              ],
            ),
            if (state.hasError)
              Text(
                "${state.errorText}",
                style: TextStyle(color: Theme.of(context).errorColor),
              ),
          ],
        );
      },
    );
  }
}
