import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/defines.dart';
import 'package:flutter/material.dart';

class SmsCodeInput extends StatefulWidget {
  SmsCodeInput({
    required this.success,
    required this.error,
    this.submitTitle = const SizedBox.shrink(),
    required this.submitButton,
    this.smsCodeInputDecoration = const InputDecoration(),
    this.smsCodeInputTextStyle = const TextStyle(),
    Key? key,
  }) : super(key: key);
  final VoidCallback success;
  final ErrorCallback error;

  final Widget Function(int length, VoidNullableCallback submit) submitButton;
  final Widget submitTitle;

  final InputDecoration smsCodeInputDecoration;
  final TextStyle smsCodeInputTextStyle;

  @override
  _SmsCodeInputState createState() => _SmsCodeInputState();
}

class _SmsCodeInputState extends State<SmsCodeInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (t) => setState(() => PhoneService.instance.smsCode = t),
          style: widget.smsCodeInputTextStyle,
          decoration: widget.smsCodeInputDecoration,
        ),
        widget.submitTitle,
        widget.submitButton(PhoneService.instance.smsCode.length, submit),
      ],
    );
  }

  submit() {
    PhoneService.instance.verifySMSCode(
      success: widget.success,
      error: widget.error,
    );
  }
}
