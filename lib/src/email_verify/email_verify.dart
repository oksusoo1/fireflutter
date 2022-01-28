import 'dart:async';

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class EmailVerify extends StatefulWidget {
  const EmailVerify({
    required this.onVerified,
    required this.onError,
    required this.onCancel,
    required this.onRelogin,
    Key? key,
  }) : super(key: key);

  final Function onVerified;
  final Function onCancel;
  final Function(dynamic) onError;
  final Function(String) onRelogin;

  @override
  _EmailVerifyState createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerify> {
  EmailVerifyService emailVerifyService = EmailVerifyService.instance;

  TextEditingController emailInputController = TextEditingController(
    text: EmailVerifyService.instance.userEmail,
  );

  @override
  void initState() {
    super.initState();

    if (emailVerifyService.userHasEmail) {
      sendVerificationEmail();
    }
  }

  Future sendVerificationEmail() async {
    try {
      print('userHasEmail');
      emailVerifyService.sendEmailVerification();
    } catch (e) {
      widget.onError(e);
    }
  }

  Future updateUserEmail() async {
    try {
      await emailVerifyService.updateUserEmail(
        emailInputController.text,
      );
      if (mounted) setState(() {});
    } catch (e) {
      if (e.toString().contains('requires-recent-login')) {
        widget.onRelogin(emailInputController.text);
        await updateUserEmail();
      }
      widget.onError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return emailVerifyService.userHasEmail
        ? Column(
            children: [
              Text('Verification is sent to your email.'),
              TextButton(
                child: Text('Resend'),
                onPressed: () {
                  /// TODO resend email verification.
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () => widget.onCancel(),
              ),
            ],
          )
        : Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: emailInputController,
                  decoration: const InputDecoration(hintText: 'Enter Email'),
                ),
                TextButton(
                  child: const Text('Send Verification'),
                  onPressed: () => updateUserEmail(),
                ),
              ],
            ),
          );
  }
}
