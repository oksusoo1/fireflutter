import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class SmsCodeInput extends StatefulWidget {
  SmsCodeInput({
    required this.success,
    required this.error,
    this.submitTitle = const SizedBox.shrink(),
    required this.submitButton,
    this.smsCodeInputDecoration = const InputDecoration(),
    this.smsCodeInputTextStyle = const TextStyle(),
    this.cancelButton,
    Key? key,
  }) : super(key: key);
  final VoidCallback success;
  final ErrorCallback error;

  final Widget Function(VoidNullableCallback submit) submitButton;
  final Widget Function()? cancelButton;
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
        Row(
          children: [
            widget.submitButton(submit),
            Spacer(),
            if (widget.cancelButton != null) widget.cancelButton!()
          ],
        ),
      ],
    );
  }

  submit() async {
    setState(() {
      PhoneService.instance.verifySentProgress = true;
    });
    await PhoneService.instance.verifySMSCode(
      success: widget.success,
      error: widget.error,
    );
    setState(() {
      if (mounted) PhoneService.instance.verifySentProgress = false;
    });
  }
}
