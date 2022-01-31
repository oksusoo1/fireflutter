import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import './email_verification.service.dart';

class EmailVerification extends StatefulWidget {
  EmailVerification({
    Key? key,
    required this.onVerified,
    required this.onError,
    required this.onVerificationEmailSent,
    required this.onTooManyRequests,
    required this.onUpdateEmail,
    required this.onUserTokenExpired,
  }) : super(key: key);

  final Function(bool updated) onVerified;
  final Function(dynamic) onError;
  final Function onVerificationEmailSent;
  final Function onTooManyRequests;

  final Function onUserTokenExpired;

  /// To update email, it may need to open dialog (or another screen) to
  ///   re-authenticate the login if the user logged in long time ago.
  ///   so, updating the email address should be done one root app for UI.
  final Function(String email, Function callback) onUpdateEmail;

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  bool emailVerificationCodeSent = false;
  bool emailChanged = false;
  final email = TextEditingController(text: FirebaseAuth.instance.currentUser!.email);
  final String? orgEmail = FirebaseAuth.instance.currentUser?.email;
  bool get emailVerified => FirebaseAuth.instance.currentUser!.emailVerified;

  bool loading = false;

  final _emailService = EmailVerificationService.instance;

  @override
  void initState() {
    super.initState();

    _emailService.init(
      onVerified: () => widget.onVerified((orgEmail == email.text)),
      onError: widget.onError,
      onVerificationEmailSent: () {
        setState(() {
          emailVerificationCodeSent = true;
        });

        /// if email has changed, then it returns true.
        widget.onVerificationEmailSent();
      },

      /// All error(exception) goes to [onError] except, too many requests.
      onTooManyRequests: widget.onTooManyRequests,
      onUserTokenExpired: widget.onUserTokenExpired,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _emailService.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: email,
          onChanged: (v) => setState(() {
            emailChanged = true;
            emailVerificationCodeSent = false;
          }),
        ),
        loading
            ? Center(child: const CircularProgressIndicator.adaptive())
            : emailVerificationCodeSent
                ? ElevatedButton(
                    onPressed: () async {
                      try {
                        setState(() => loading = true);
                        await _emailService.sendVerificationEmail();
                      } catch (e) {
                        widget.onError(e);
                      } finally {
                        setState(() => loading = false);
                      }
                    },
                    child: const Text('Re-send'),
                  )
                : ElevatedButton(
                    onPressed: (emailChanged || !emailVerified) ? verifyEmail : null,
                    child: Text(
                      (emailChanged || emailVerified) ? 'Update email' : 'Verify email',
                    ),
                  ),
      ],
    );
  }

  /// verify email or update mail had been pressed.
  verifyEmail() async {
    if (emailChanged) {
      if (emailChanged) {
        /// onUpdateEmail() is not async/await. So, we do not know when it will
        /// be finished.
        /// So, just put 10 seconds of loader. the loader will be disappear 10
        /// seconds later or when the verification email had sent.
        setState(() => loading = true);
        Timer(Duration(seconds: 10), () => setState(() => loading = false));
        widget.onUpdateEmail(email.text, () async {
          sendVerificationLink();
        });
      }
    } else {
      sendVerificationLink();
    }
  }

  /// Send verification link to email box.
  sendVerificationLink() async {
    try {
      setState(() => loading = true);
      await _emailService.sendVerificationEmail();
    } catch (e) {
      widget.onError(e);
    } finally {
      setState(() => loading = false);
    }
  }
}
