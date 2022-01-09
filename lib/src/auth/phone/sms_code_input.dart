import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/defines.dart';
import 'package:flutter/material.dart';

class SmsCodeInput extends StatefulWidget {
  SmsCodeInput({required this.success, required this.error, Key? key}) : super(key: key);
  final VoidCallback success;
  final ErrorCallback error;
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
        if (PhoneService.instance.smsCode != '')
          ElevatedButton(
              onPressed: () {
                PhoneService.instance.verifySMSCode(
                  success: widget.success,
                  error: widget.error,
                );
              },
              child: Text('Submit'))
      ],
    );
  }
}
