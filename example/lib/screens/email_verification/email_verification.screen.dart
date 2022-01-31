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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Verification')),
      body: EmailVerificationService.instance.userHasPhoneNumber == false
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
                EmailVerification(
                  onVerified: (re) async {
                    await alert(
                      'Success',
                      re ? 'Email verfied.' : 'Email had been updated and verified.',
                    );
                    Get.toNamed('/home');
                  },
                  onError: error,
                  onVerificationEmailSent: () => alert(
                    'Email verification',
                    'Please open your email box and click the verification link.',
                  ),
                  onTooManyRequests: () => alert(
                    'Error',
                    'Oops, you have requested too many email verification. Please do a while later.',
                  ),

                  /// User sign-in credential is no longer valid. User must sign-in again.
                  ///
                  /// This error happens sometimes. go to login page and let user login again and come back.
                  onUserTokenExpired: () async {
                    await alert(
                      'Login again',
                      'Your login is no longer valid. You must sign-in again.',
                    );
                    Get.toNamed('/home');
                  },
                  onUpdateEmail: updateEmail,
                ),
              ],
            ),
    );
  }

  Future<void> updateEmail(
    String email,
    Function callback,
  ) async {
    try {
      await FirebaseAuth.instance.currentUser!.updateEmail(email);
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
                await onReAuthenticationSuccess(email);
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
            await onReAuthenticationSuccess(email);
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
  Future<void> onReAuthenticationSuccess(String email) async {
    /// User re-logged in.
    try {
      /// Email updated after re-login.
      await FirebaseAuth.instance.currentUser!.updateEmail(email);
      Get.back();
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
