import 'package:extended/extended.dart';
import 'package:fe/screens/email_verify/email_verify.input_email.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmailVerifyScreen extends StatefulWidget {
  const EmailVerifyScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  onEmailVerified() {
    Get.defaultDialog(
      middleText: 'Email verification success',
      textConfirm: 'Ok',
    ).then((value) => Get.offAllNamed('/home'));
  }

  // onError(String title, dynamic error) {
  //   Get.defaultDialog(
  //     title: title,
  //     middleText: error.toString(),
  //     textConfirm: 'Ok',
  //     onConfirm: () => Get.back(),
  //   );
  // }

  onVerificationEmailSent() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verify'),
      ),
      body: EmailVerifyService.instance.userHasEmail
          ? EmailVerify(
              onVerified: () => onEmailVerified(),
              onError: error,
              cancelButtonBuilder: () => TextButton(
                child: const Text('Cancel'),
                onPressed: () => Get.back(),
              ),
              resendButtonBuilder: (callback) => TextButton(
                child: const Text('Resend'),
                onPressed: () => callback(),
              ),
            )
          : EmailVerifyInputEmail(
              onVerificationEmailSent: onVerificationEmailSent,
              onError: error,
            ),
    );
  }
}
