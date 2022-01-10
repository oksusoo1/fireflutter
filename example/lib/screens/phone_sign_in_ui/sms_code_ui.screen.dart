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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Custom design
            Text('Phone No. ${PhoneService.instance.phoneNumber}'),
            const SizedBox(height: 16),
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

              /// sms code input box decoration
              smsCodeInputDecoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),

              /// sms code input text style
              smsCodeInputTextStyle: const TextStyle(fontSize: 24),

              submitTitle: Column(
                children: const [
                  SizedBox(height: 16),
                  Text('Enter sms code and submit'),
                ],
              ),

              /// This is the submit button builder.
              ///
              /// The builder function has [submit] function parameter that
              /// submits the code to verify.
              ///
              ///  You can customize the UI like below.
              submitButton: (submit) => Row(
                children: [
                  PhoneService.instance.verifySentProgress
                      ? const CircularProgressIndicator.adaptive()
                      : ElevatedButton(
                          onPressed: PhoneService.instance.smsCode.length == 6 ? submit : null,
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
