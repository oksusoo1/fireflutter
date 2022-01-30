import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
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
      onVerified: () async {
        await alert(
          'Success',
          orgEmail == email.text ? 'Email verfied.' : 'Email had been updated and verified.',
        );
        Get.toNamed('/home');
      },
      onError: error,
      onVerificationEmailSent: () {
        setState(() {
          emailVerificationCodeSent = true;
        });
        alert(
          'Email verification',
          'Please open your email box and click the verification link.',
        );
      },

      /// All error(exception) goes to [onError] except, too many requests.
      onTooManyRequests: () => alert(
        'Error',
        'Oops, you have requested too many email verification. Please do a while later.',
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _emailService.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Verification')),
      body: _emailService.userHasPhoneNumber == false
          ? const Text(
              'You have no phone number. Login with phone number first.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
              ),
            )
          : Column(
              children: [
                const UserInfo(),
                TextField(
                  controller: email,
                  onChanged: (v) => setState(() {
                    emailChanged = true;
                    emailVerificationCodeSent = false;
                  }),
                ),
                loading
                    ? const Spinner()
                    : emailVerificationCodeSent
                        ? ElevatedButton(
                            onPressed: () async {
                              try {
                                setState(() => loading = true);
                                await _emailService.sendVerificationEmail();
                              } catch (e) {
                                error(e);
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
            ),
    );
  }

  /// verify email or update mail had been pressed.
  verifyEmail() async {
    if (emailChanged) {
      if (emailChanged) {
        updateEmail(() async {
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
      error(e);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> updateEmail(Function callback) async {
    try {
      await FirebaseAuth.instance.currentUser!.updateEmail(email.text);
      callback();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        /// User logged in long time agao. Needs to re-login to update email address.
        PhoneService.instance.phoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber!;
        await PhoneService.instance.verifyPhoneNumber(
          /// Once verification code is send via SMS, show a dialog input for the code.
          codeSent: (verificationId) => Get.defaultDialog(
            title: 'Enter SMS Code to verify it\'s you.',
            content: SmsCodeInput(
              success: () async {
                await onReAuthenticationSuccess();
                callback();
              },
              error: error,
              submitButton: (callback) => TextButton(
                child: const Text('Submit'),
                onPressed: callback,
              ),
            ),
          ),
          androidAutomaticVerificationSuccess: () async {
            await onReAuthenticationSuccess();
            callback();
          },
          error: error,
          codeAutoRetrievalTimeout: (String verificationId) {
            Get.defaultDialog(
              middleText: 'SMS code timeouted. Please send it again',
              textConfirm: 'Ok',
            );
          },
        );
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  ///
  Future<void> onReAuthenticationSuccess() async {
    /// User re-logged in.
    try {
      /// Email updated after re-login.
      await FirebaseAuth.instance.currentUser!.updateEmail(email.text);
      Get.back();
      setState(() => loading = false);
    } catch (e) {
      error(e);
    }
  }
}

class UserInfo extends StatelessWidget {
  const UserInfo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;
    return Text('''
Uid: ${user.uid},
Phone number: ${user.phoneNumber}
Email: ${user.email},
Email has ${user.emailVerified ? '' : 'NOT...'} verified.
              ''');
  }
}
