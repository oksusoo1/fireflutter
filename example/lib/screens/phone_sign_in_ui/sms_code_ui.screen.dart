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
            Text('Phone No. ${PhoneService.instance.phoneNumber}'),
            const Text('Please input SMS verification code'),
            SmsCodeInput(
              success: () => Get.defaultDialog(
                  middleText: 'Phone sign-in success',
                  textConfirm: 'Ok',
                  onConfirm: () => Get.back()).then(
                (value) => Get.offAllNamed('/home'),
              ),
              error: (e) => Get.defaultDialog(
                middleText: e.toString(),
                textConfirm: 'Ok',
                onConfirm: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
