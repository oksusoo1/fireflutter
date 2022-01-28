import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmailVerifyInputEmail extends StatelessWidget {
  EmailVerifyInputEmail({
    required this.onVerificationEmailSent,
    required this.onError,
    Key? key,
  }) : super(key: key);

  final Function onVerificationEmailSent;
  final Function(dynamic) onError;

  final firebaseAuth = FirebaseAuth.instance;
  final TextEditingController emailInputController = TextEditingController(
    text: EmailVerifyService.instance.userEmail,
  );

  Future updateUserEmail() async {
    try {
      /// Update user email.
      await EmailVerifyService.instance.updateUserEmail(
        email: emailInputController.text,
        onReAuthenticate: (callback) {},
      );

      /// Once email update is successful, send an email verification.
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      onVerificationEmailSent();
    } catch (e) {
      onError(e);
    }
  }

  onReauthentication(Function reloginCallback) {
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
          error: (e) => onError(e),
          submitButton: (callback) => TextButton(
            child: const Text('Submit'),
            onPressed: callback,
          ),
        ),
      ),
      success: () => Get.back(),
      error: (e) => onError(e),
      codeAutoRetrievalTimeout: (String verificationId) {
        Get.defaultDialog(
          middleText: 'SMS code timeouted. Please send it again',
          textConfirm: 'Ok',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: emailInputController,
            decoration: const InputDecoration(hintText: 'Enter Email'),
          ),
          TextButton(
            child: const Text('Update and Verify'),
            onPressed: () => updateUserEmail(),
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }
}
