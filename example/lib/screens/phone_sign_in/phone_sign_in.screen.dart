import 'package:extended/extended.dart';
import 'package:fe/screens/phone_sign_in/sms_code.screen.dart';
import 'package:fe/service/app.service.dart';
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
                  codeSent: (verificationId) =>
                      AppService.instance.open(SmsCodeScreen.routeName),
                  androidAutomaticVerificationSuccess: () {
                    alert('Phone sign-in success', 'You have signed-in.');
                    AppService.instance.openHome();

                    // Get.defaultDialog(
                    //   middleText: 'Phone sign-in success',
                    //   textConfirm: 'Ok',
                    // ).then((value) => Get.offAllNamed('/home'));
                  },
                  error: (e) => error(e),
                  codeAutoRetrievalTimeout: (String verificationId) {
                    alert(
                        'Timeout', 'SMS code timeouted. Please send it again');
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
