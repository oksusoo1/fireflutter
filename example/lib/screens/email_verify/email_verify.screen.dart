import 'package:fireflutter/fireflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmailVerifyScreen extends StatelessWidget {
  const EmailVerifyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verify'),
      ),
      body: EmailVerify(
        onVerified: () => Get.back(),
        onError: print,
        onCancel: () => Get.back(),
        onRelogin: (String email) {
          PhoneService.instance.phoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber!;
          PhoneService.instance.verifyPhoneNumber(
            codeSent: (verificationId) => Get.toNamed('/sms-code'),
            success: () {
              Get.defaultDialog(
                middleText: 'Phone sign-in success',
                textConfirm: 'Ok',
              ).then((value) => Get.back());
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
      ),
    );
  }
}
