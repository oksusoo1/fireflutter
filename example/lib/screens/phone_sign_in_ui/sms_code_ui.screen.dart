import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SmsCodeUIScreen extends StatefulWidget {
  const SmsCodeUIScreen({Key? key}) : super(key: key);

  @override
  _SmsCodeUIScreenState createState() => _SmsCodeUIScreenState();
}

class _SmsCodeUIScreenState extends State<SmsCodeUIScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS code verification (UI)'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Custom design
            Text('Phone No. ${PhoneService.instance.phoneNumber}'),
            const Text('Please input SMS verification code'),

            /// SMS code input widget
            SmsCodeInput(
              /// on success,
              success: () => Get.defaultDialog(
                  middleText: 'Phone sign-in success',
                  textConfirm: 'Ok',
                  onConfirm: () => Get.back()).then(
                (value) => Get.offAllNamed('/home'),
              ),

              /// on error,
              error: (e) => Get.defaultDialog(
                middleText: e.toString(),
                textConfirm: 'Ok',
                onConfirm: () => Get.back(),
              ),

              /// This is the submit button builder.
              ///
              /// The builder function has [visible] and [submit].
              /// [visible] is to display the submit button or not.
              /// [submit] is the callback to be called to submit.
              ///
              ///  You can customize the UI like below.
              submitButton: (bool visible, submit) => Row(
                children: [
                  ElevatedButton(
                    onPressed: visible ? submit : null,
                    child: const Text('Submit'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: Get.back,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
