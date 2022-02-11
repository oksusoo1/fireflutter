import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PhoneSignInScreen extends StatefulWidget {
  const PhoneSignInScreen({Key? key}) : super(key: key);

  static const String routeName = '/phone-sign-in';

  @override
  _PhoneSignInScreenState createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Sign In'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Enter country dial code and phone number'),
            TextField(
              onChanged: (t) => PhoneService.instance.phoneNumber = t,
            ),
            ElevatedButton(
              onPressed: () {
                PhoneService.instance.verifyPhoneNumber(
                  codeSent: (verificationId) => Get.toNamed('/sms-code'),
                  androidAutomaticVerificationSuccess: () {
                    Get.defaultDialog(
                      middleText: 'Phone sign-in success',
                      textConfirm: 'Ok',
                    ).then((value) => Get.offAllNamed('/home'));
                  },
                  error: (e) {
                    Get.defaultDialog(
                      title: 'Phone sign-in error',
                      middleText: e.toString(),
                      textConfirm: 'Ok',
                    );
                  },
                  codeAutoRetrievalTimeout: (String verificationId) {
                    Get.defaultDialog(
                      middleText: 'SMS code timeouted. Please send it again',
                      textConfirm: 'Ok',
                    );
                  },
                );
              },
              child: const Text('Verify'),
            )
          ],
        ),
      ),
    );
  }
}
