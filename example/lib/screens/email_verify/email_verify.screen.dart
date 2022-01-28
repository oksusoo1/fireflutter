import 'dart:async';

import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class EmailVerifyScreen extends StatefulWidget {
  const EmailVerifyScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  bool emailVerificationCodeSent = false;
  bool emailChanged = false;
  final email = TextEditingController(text: FirebaseAuth.instance.currentUser!.email);
  final String? orgEmail = FirebaseAuth.instance.currentUser?.email;
  bool get emailVerified => FirebaseAuth.instance.currentUser!.emailVerified;

  Timer? timer;

  bool loading = false;

  listenToEmailVerification() {
    /// Note, if the user closes the screen before verifying the email?
    ///   - just ignore this case, the user's email will be verified any way.
    ///
    /// Initialize email verification checker.
    /// It will unsubscribe / stop when:
    ///  A. Email verification process is done.
    ///  B. User cancels the operation by pressing cancel button.
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) async {
        print('check verification result');
        await FirebaseAuth.instance.currentUser!.reload();
        if (FirebaseAuth.instance.currentUser!.emailVerified) {
          timer.cancel();
          await alert(
            'Success',
            orgEmail == email.text ? 'Email verfied.' : 'Email had been updated and verified.',
          );
          Get.toNamed('/home');
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verify'),
      ),
      body: FirebaseAuth.instance.currentUser?.phoneNumber == null
          ? const Text(
              'You have no phone no. Login with phone number first.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
              ),
            )
          : Column(
              children: [
                Text('''
              uid: ${user.uid},
              email: ${user.email},
              phoneNo: ${user.phoneNumber}
              '''),
                TextField(
                  controller: email,
                  onChanged: (v) => setState(() {
                    emailChanged = true;
                    emailVerificationCodeSent = false;
                  }),
                ),
                loading
                    ? const Spinner()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (emailVerificationCodeSent)
                            ElevatedButton(
                                onPressed: () async {
                                  setState(() => loading = true);
                                  await sendVerificationEmail();
                                  setState(() => loading = false);
                                },
                                child: const Text('Resend')),
                          ElevatedButton(
                            onPressed: (emailChanged || !emailVerified)
                                ? () async {
                                    setState(() => loading = true);
                                    try {
                                      await FirebaseAuth.instance.currentUser!
                                          .updateEmail(email.text);
                                      await sendVerificationEmail();
                                    } on FirebaseAuthException catch (e) {
                                      if (e.code == 'requires-recent-login') {
                                        /// User logged in long time agao. Needs to re-login to update email address.
                                        PhoneService.instance.phoneNumber =
                                            FirebaseAuth.instance.currentUser!.phoneNumber!;
                                        PhoneService.instance.verifyPhoneNumber(
                                          /// Once verification code is send via SMS, show a dialog input for the code.
                                          codeSent: (verificationId) => Get.defaultDialog(
                                            title: 'Enter SMS Code to verify it\'s you.',
                                            content: SmsCodeInput(
                                              success: () async {
                                                /// User re-logged in.
                                                Get.back();
                                                try {
                                                  /// Email updated after re-login.
                                                  await FirebaseAuth.instance.currentUser!
                                                      .updateEmail(email.text);
                                                  await sendVerificationEmail();
                                                  setState(() => loading = false);
                                                } catch (e) {
                                                  error(e);
                                                }
                                              },
                                              error: error,
                                              submitButton: (callback) => TextButton(
                                                child: const Text('Submit'),
                                                onPressed: callback,
                                              ),
                                            ),
                                          ),
                                          success: () => Get.back(),
                                          error: error,
                                          codeAutoRetrievalTimeout: (String verificationId) {
                                            Get.defaultDialog(
                                              middleText:
                                                  'SMS code timeouted. Please send it again',
                                              textConfirm: 'Ok',
                                            );
                                          },
                                        );
                                      } else {
                                        setState(() => loading = false);
                                        error(e);
                                        return;
                                      }
                                    } catch (e) {
                                      setState(() => loading = false);
                                      error(e);
                                      return;
                                    }

                                    setState(() => loading = false);
                                  }
                                : null,
                            child: Text(
                              (emailChanged || emailVerified) ? 'Update email' : 'Verify email',
                            ),
                          ),
                        ],
                      )
              ],
            ),
    );
  }

  sendVerificationEmail() async {
    /// Once email update is successful, send an email verification.
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      listenToEmailVerification();
      alert('Email verification', 'Please open your email box and click the verification link.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'firebase_auth/too-many-requests') {
        alert('Error', 'slow down');
      } else {
        error(e);
      }
    } catch (e) {
      error(e);
    }
    setState(() {
      emailVerificationCodeSent = true;
    });
  }
}
