import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class EmailVerify extends StatefulWidget {
  const EmailVerify({
    required this.onVerified,
    required this.onError,
    required this.resendButtonBuilder,
    required this.cancelButtonBuilder,
    Key? key,
  }) : super(key: key);

  final Function onVerified;
  final Function(dynamic) onError;
  final WidgetFunctionCallback resendButtonBuilder;
  final WidgetFunction cancelButtonBuilder;

  @override
  _EmailVerifyState createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerify> {
  Timer? timer;
  EmailVerifyService emailVerifyService = EmailVerifyService.instance;

  bool canResendVerification = false;

  @override
  void initState() {
    super.initState();

    /// If user has email, it will automatically send a verification email.
    if (emailVerifyService.userHasEmail) {
      resendVerificationEmail();
    }

    /// Initialize email verification checker.
    /// It will unsubscribe / stop when:
    ///  A. Email verification process is done.
    ///  B. User cancels the operation by pressing cancel button.
    timer = Timer.periodic(
      Duration(seconds: 3),
      (timer) => emailVerifyService.checkEmailVerified(
        onVerified: () => onEmailVerified(),
      ),
    );
  }

  Future resendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      if (mounted) setState(() => canResendVerification = false);
      await Future.delayed(Duration(seconds: 5));
      if (mounted) setState(() => canResendVerification = true);
    } catch (e) {
      widget.onError(e);
    }
  }

  onEmailVerified() {
    timer?.cancel();
    widget.onVerified();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Verification is sent to your email.'),
        
        widget.resendButtonBuilder(resendVerificationEmail),
        widget.cancelButtonBuilder(),
      ],
    );
  }
}
