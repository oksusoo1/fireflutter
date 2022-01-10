import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/defines.dart';
import 'package:flutter/material.dart';

class SmsCodeInput extends StatefulWidget {
  SmsCodeInput({
    required this.success,
    required this.error,
    this.submitTitle = const SizedBox.shrink(),
    required this.submitButton,
    Key? key,
  }) : super(key: key);
  final VoidCallback success;
  final ErrorCallback error;

  final Widget Function(bool visible, VoidNullableCallback submit) submitButton;
  final Widget submitTitle;

  @override
  _SmsCodeInputState createState() => _SmsCodeInputState();
}

class _SmsCodeInputState extends State<SmsCodeInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (t) => setState(() => PhoneService.instance.smsCode = t),
        ),
        widget.submitButton(PhoneService.instance.smsCode != '', submit),
        // if (PhoneService.instance.smsCode != '')
        //   GestureDetector(
        //     behavior: HitTestBehavior.opaque,
        //     onTap: () {
        //       PhoneService.instance.verifySMSCode(
        //         success: widget.success,
        //         error: widget.error,
        //       );
        //     },
        //     child: widget.submitButton,
        //   )
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
