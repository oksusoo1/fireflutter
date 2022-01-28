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

/// TODO: hide resend on email edit

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  // onEmailVerified() {
  //   Get.defaultDialog(
  //     middleText: 'Email verification success',
  //     textConfirm: 'Ok',
  //   ).then((value) => Get.offAllNamed('/home'));
  // }

  // onVerificationEmailSent() {
  //   if (mounted) setState(() {});
  // }

  bool emailVerificationCodeSent = false;
  final email = TextEditingController(text: FirebaseAuth.instance.currentUser!.email);
  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verify'),
      ),
      body: Column(
        children: [
          Text('''
              uid: ${user.uid},
              email: ${user.email}
              '''),
          TextField(
            controller: email,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (emailVerificationCodeSent)
                ElevatedButton(onPressed: () {}, child: const Text('Resend')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.currentUser!.updateEmail(email.text);
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 're-login') {
                      /// User logged in long time agao. Needs to re-login to update email address.
                      PhoneService.instance.phoneNumber =
                          FirebaseAuth.instance.currentUser!.phoneNumber!;
                      PhoneService.instance.verifyPhoneNumber(
                        /// Once verification code is send via SMS, show a dialog input for the code.
                        codeSent: (verificationId) => Get.defaultDialog(
                          title: 'Enter SMS Code to verify it\'s you.',
                          content: SmsCodeInput(
                            success: () {
                              /// User re-logged in.
                              Get.back();

                              /// Email updated after re-login.
                              FirebaseAuth.instance.currentUser!
                                  .updateEmail(email.text)
                                  .catchError(error);
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
                            middleText: 'SMS code timeouted. Please send it again',
                            textConfirm: 'Ok',
                          );
                        },
                      );
                    } else {
                      error(e);
                    }
                  } catch (e) {
                    error(e);
                  }

                  /// Once email update is successful, send an email verification.
                  try {
                    await FirebaseAuth.instance.currentUser!.sendEmailVerification();
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
                },
                child: Text(user.emailVerified ? 'Update email' : 'Verify email'),
              ),
            ],
          )
        ],
      ),

      // EmailVerifyService.instance.userHasEmail
      //     ? EmailVerify(
      //         onVerified: () => onEmailVerified(),
      //         onError: error,
      //         cancelButtonBuilder: () => TextButton(
      //           child: const Text('Cancel'),
      //           onPressed: () => Get.back(),
      //         ),
      //         resendButtonBuilder: (callback) => TextButton(
      //           child: const Text('Resend'),
      //           onPressed: () => callback(),
      //         ),
      //       )
      //     : EmailVerifyInputEmail(
      //         onVerificationEmailSent: onVerificationEmailSent,
      //         onError: error,
      //       ),
    );
  }
}
