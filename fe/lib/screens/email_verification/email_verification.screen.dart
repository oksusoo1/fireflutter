import 'package:extended/extended.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef FutureFunction = Future Function();

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  static const String routeName = '/emailVerification';

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
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
                  actionCodeSettings: ActionCodeSettings(
                    url: 'https://withcentertest.page.link/email-verification',
                    dynamicLinkDomain: 'withcentertest.page.link',
                    androidPackageName: 'com.withcenter.test',
                    iOSBundleId: 'com.withcenter.test',
                  ),
                  onVerified: (re) async {
                    await alert(
                      'Success',
                      re
                          ? 'Email verfied.'
                          : 'Email had been updated and verified.',
                    );
                    AppService.instance.openHome();
                  },
                  onError: error,
                  onVerificationEmailSent: (email) => alert(
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
                    AppService.instance.openHome();
                  },
                  onUpdateEmail: updateEmail,
                ),
              ],
            ),
    );
  }

  Future<void> updateEmail(
    String email,
    FutureFunction callback,
  ) async {
    try {
      await FirebaseAuth.instance.currentUser!.updateEmail(email);
      await callback();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        /// User logged in long time agao. Needs to re-login to update email address.
        PhoneService.instance.phoneNumber =
            FirebaseAuth.instance.currentUser!.phoneNumber!;
        await PhoneService.instance.verifyPhoneNumber(
          /// Once verification code is send via SMS, show a dialog input for the code.
          codeSent: (verificationId) async {
            showDialog(
                context: context,
                builder: (c) {
                  return Dialog(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 16),
                          const Text("Enter SMS Code to verify it's you."),
                          SmsCodeInput(
                            success: () => onReAuthenticationSuccess(email)
                                .then((value) => callback()),
                            error: error,
                            buttons: (callback) => TextButton(
                              child: const Text('Submit'),
                              onPressed: callback,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });

            //   Get.defaultDialog(
            //   title: ,
            //   content: SmsCodeInput(
            //     success: () => onReAuthenticationSuccess(email).then((value) => callback()),
            //     error: error,
            //     submitButton: (callback) => TextButton(
            //       child: const Text('Submit'),
            //       onPressed: callback,
            //     ),
            //   ),
            // );
          },
          androidAutomaticVerificationSuccess: () =>
              onReAuthenticationSuccess(email).then(
            (value) => callback(),
          ),
          error: error,
          codeAutoRetrievalTimeout: (String verificationId) {
            alert(
              'Timeout',
              'SMS code timeouted. Please send it again',
            );
          },
        );
      } else {
        error(e);
      }
    } catch (e) {
      error(e);
    }
  }

  ///
  Future<void> onReAuthenticationSuccess(String email) async {
    /// User re-logged in.
    try {
      /// Email updated after re-login.
      await FirebaseAuth.instance.currentUser!.updateEmail(email);
      AppService.instance.back();
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
