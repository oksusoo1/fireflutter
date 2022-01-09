import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/defines.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';

class PhoneNumberInput extends StatefulWidget {
  PhoneNumberInput({
    this.favorites = const ['US', 'KR'],
    this.onChanged,
    required this.selectBuilder,
    required this.selectedBuilder,
    required this.codeSent,
    required this.error,
    required this.success,
    required this.codeAutoRetrievalTimeout,
    Key? key,
  }) : super(key: key);

  final List<String> favorites;
  final void Function(CountryCode)? onChanged;
  final Widget Function() selectBuilder;
  final Widget Function(CountryCode) selectedBuilder;
  final void Function(String verificationId) codeSent;
  final VoidCallback success;
  final ErrorCallback error;
  final void Function(String) codeAutoRetrievalTimeout;

  @override
  _PhoneNumberInputState createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends State<PhoneNumberInput> {
  @override
  void initState() {
    super.initState();

    PhoneService.instance.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CountryCodePicker(
          onChanged: (CountryCode code) {
            PhoneService.instance.selectedCode = code;
            if (widget.onChanged != null) widget.onChanged!(code);
            setState(() {});
          },
          favorite: widget.favorites,
          comparator: (a, b) {
            /// sort by country dial code
            int re = b.dialCode!.compareTo(a.dialCode!);
            return re == 0 ? 0 : (re < 0 ? 1 : -1);
          },
          builder: (CountryCode? code) {
            return PhoneService.instance.selectedCode == null
                ? widget.selectBuilder()
                : widget.selectedBuilder(code!);
          },
        ),
        if (PhoneService.instance.selectedCode != null)
          Row(
            children: [
              Text(
                PhoneService.instance.selectedCode!.dialCode!,
              ),
              SizedBox(width: 8),
              Expanded(
                  child: TextField(
                keyboardType: TextInputType.phone,
                onChanged: (t) {
                  PhoneService.instance.domesticPhoneNumber = t;
                  setState(() {});
                },
              )),
            ],
          ),
        if (PhoneService.instance.domesticPhoneNumber != '' &&
            PhoneService.instance.codeSentProgress == false)
          ElevatedButton(
            onPressed: () {
              setState(() {
                PhoneService.instance.codeSentProgress = true;
              });
              PhoneService.instance.phoneNumber = PhoneService.instance.completeNumber;
              PhoneService.instance.verifyPhoneNumber(
                codeSent: widget.codeSent,
                success: widget.success,
                error: widget.error,
                codeAutoRetrievalTimeout: widget.codeAutoRetrievalTimeout,
              );
            },
            child: Text('Submit'),
          ),
        if (PhoneService.instance.codeSentProgress) CircularProgressIndicator.adaptive(),
      ],
    );
  }
}
