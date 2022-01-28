import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/src/email_verify/email_verify.service.dart';
import 'package:flutter/material.dart';

class EmailVerifyInputEmail extends StatelessWidget {
  EmailVerifyInputEmail({
    required this.onVerificationEmailSent,
    required this.onRelogin,
    required this.onError,
    required this.onCancel,
    Key? key,
  }) : super(key: key);

  final Function onVerificationEmailSent;
  final Function onCancel;
  final Function(dynamic) onError;
  final Function(Function) onRelogin;

  final firebaseAuth = FirebaseAuth.instance;
  final TextEditingController emailInputController = TextEditingController(
    text: EmailVerifyService.instance.userEmail,
  );

  Future updateUserEmail() async {
    try {
      /// Update user email.
      await FirebaseAuth.instance.currentUser!.updateEmail(emailInputController.text);

      /// Once email update is successful, send an email verification.
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      onVerificationEmailSent();
    } catch (e) {
      /// If email update required re authentication.
      /// 1. Execute relogin function,
      /// 2. Call this function again.
      if (e.toString().contains('requires-recent-login')) {
        onRelogin(updateUserEmail);
      } else {
        onError(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
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
            onPressed: () => onCancel(),
          ),
        ],
      ),
    );
  }
}
