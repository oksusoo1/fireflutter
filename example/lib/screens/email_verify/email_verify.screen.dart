import 'package:fireflutter/fireflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  onError(String title, dynamic error) {
    Get.defaultDialog(
      title: title,
      middleText: error.toString(),
      textConfirm: 'Ok',
      onConfirm: () => Get.back(),
    );
  }

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
              onError: (e) => onError('Email verification error', e),
              onCancel: () => Get.back(),
            )
          : EmailVerifyInputEmail(
              onVerificationEmailSent: onVerificationEmailSent,
              onError: (e) => onError('Email update error.', e),
              onCancel: () => Get.back(),

              /// Once re-authentication is required, verify the user again with their phone number.
              /// Call on `reloginCallback` to run the email update proccess again.
              onRelogin: (reloginCallback) {
                PhoneService.instance.phoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber!;
                PhoneService.instance.verifyPhoneNumber(
                  /// Once verification code is send via SMS, show a dialog input for the code.
                  codeSent: (verificationId) => Get.defaultDialog(
                    title: 'Enter SMS Code to verify it\'s you.',
                    content: SmsCodeInput(
                      success: () {
                        /// Remove dialog.
                        Get.back();

                        /// Begin email update process again.
                        reloginCallback();
                      },
                      error: (e) => onError('Phone sign-in error', e),
                      submitButton: (callback) => TextButton(
                        child: const Text('Submit'),
                        onPressed: callback,
                      ),
                    ),
                  ),
                  success: () => Get.back(),
                  error: (e) => onError('Phone sign-in error', e),
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
